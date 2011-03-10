package org.antlr.mojo.antlr3;

import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.ArrayList;
import java.util.Collections;
import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.net.URL;
import java.net.MalformedURLException;
import java.net.URLClassLoader;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.project.MavenProject;
import org.apache.maven.artifact.Artifact;
import org.apache.maven.artifact.DependencyResolutionRequiredException;
import org.apache.maven.artifact.versioning.ArtifactVersion;
import org.apache.maven.artifact.versioning.DefaultArtifactVersion;
import org.apache.maven.artifact.versioning.OverConstrainedVersionException;
import org.codehaus.plexus.util.StringUtils;
import org.codehaus.plexus.util.FileUtils;
import org.codehaus.plexus.compiler.util.scan.mapping.SourceMapping;
import org.codehaus.plexus.compiler.util.scan.mapping.SuffixMapping;
import org.codehaus.plexus.compiler.util.scan.SourceInclusionScanner;
import org.codehaus.plexus.compiler.util.scan.SimpleSourceInclusionScanner;
import org.codehaus.plexus.compiler.util.scan.InclusionScanException;
import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.gunit.GrammarInfo;
import org.antlr.gunit.gUnitExecutor;
import org.antlr.gunit.AbstractTest;
import org.antlr.gunit.Interp;

/**
 * Takes gUnit scripts and directly performs testing.
 *
 * @goal gunit
 *
 * @phase test
 * @requiresDependencyResolution test
 * @requiresProject true
 *
 * @author Steve Ebersole
 */
public class GUnitExecuteMojo extends AbstractMojo {
	public static final String ANTLR_GROUP_ID = "org.antlr";
	public static final String ANTLR_ARTIFACT_NAME = "antlr";
	public static final String ANTLR_RUNTIME_ARTIFACT_NAME = "antlr-runtime";

	/**
     * INTERNAL : The Maven Project to which we are attached
     *
     * @parameter expression="${project}"
     * @required
     */
    private MavenProject project;

	/**
	 * INTERNAL : The artifacts associated to the dependencies defined as part
	 * of our configuration within the project to which we are being attached.
	 *
	 * @parameter expression="${plugin.artifacts}"
     * @required
     * @readonly
	 */
	private List<Artifact> pluginArtifacts;

	/**
     * Specifies the directory containing the gUnit testing files.
     *
     * @parameter expression="${basedir}/src/test/gunit"
     * @required
     */
    private File sourceDirectory;

    /**
     * A set of patterns for matching files from the sourceDirectory that
     * should be included as gUnit source files.
     *
     * @parameter
     */
    private Set includes;

    /**
     * A set of exclude patterns.
     *
     * @parameter
     */
    private Set excludes;

	/**
     * Specifies directory to which gUnit reports should get written.
     *
     * @parameter expression="${basedir}/target/gunit-report"
     * @required
     */
    private File reportDirectory;

	/**
	 * Should gUnit functionality be completely by-passed?
	 * <p/>
	 * By default we skip gUnit tests if the user requested that all testing be skipped using 'maven.test.skip'
	 *
	 * @parameter expression="${maven.test.skip}"
	 */
	private boolean skip;

	public Set getIncludePatterns() {
		return includes == null || includes.isEmpty()
				? Collections.singleton( "**/*.testsuite" )
				: includes;
	}

	public Set getExcludePatterns() {
		return excludes == null
				? Collections.emptySet()
				: excludes;
	}


	public final void execute() throws MojoExecutionException, MojoFailureException {
		if ( skip ) {
			getLog().info( "Skipping gUnit processing" );
			return;
		}
		Artifact pluginAntlrArtifact = determinePluginAntlrArtifact();

		validateProjectsAntlrVersion( determineArtifactVersion( pluginAntlrArtifact ) );

		performExecution( determineProjectCompileScopeClassLoader( pluginAntlrArtifact ) );
	}

	private Artifact determinePluginAntlrArtifact() throws MojoExecutionException {
		for ( Artifact artifact : pluginArtifacts ) {
			boolean match = ANTLR_GROUP_ID.equals( artifact.getGroupId() )
					&& ANTLR_ARTIFACT_NAME.equals( artifact.getArtifactId() );
			if ( match ) {
				return artifact;
			}
		}
		throw new MojoExecutionException(
				"Unexpected state : could not locate " + ANTLR_GROUP_ID + ':' + ANTLR_ARTIFACT_NAME +
						" in plugin dependencies"
		);
	}

	private ArtifactVersion determineArtifactVersion(Artifact artifact) throws MojoExecutionException {
		try {
			return artifact.getVersion() != null
					? new DefaultArtifactVersion( artifact.getVersion() )
					: artifact.getSelectedVersion();
		}
		catch ( OverConstrainedVersionException e ) {
			throw new MojoExecutionException( "artifact [" + artifact.getId() + "] defined an overly constrained version range" );
		}
	}

	private void validateProjectsAntlrVersion(ArtifactVersion pluginAntlrVersion) throws MojoExecutionException {
		Artifact antlrArtifact = null;
		Artifact antlrRuntimeArtifact = null;

		if ( project.getCompileArtifacts() != null ) {
			for ( Object o : project.getCompileArtifacts() ) {
				final Artifact artifact = ( Artifact ) o;
				if ( ANTLR_GROUP_ID.equals( artifact.getGroupId() ) ) {
					if ( ANTLR_ARTIFACT_NAME.equals( artifact.getArtifactId() ) ) {
						antlrArtifact = artifact;
						break;
					}
					if ( ANTLR_RUNTIME_ARTIFACT_NAME.equals( artifact.getArtifactId() ) ) {
						antlrRuntimeArtifact = artifact;
					}
				}
			}
		}

		validateBuildTimeArtifact( antlrArtifact, pluginAntlrVersion );
		validateRunTimeArtifact( antlrRuntimeArtifact, pluginAntlrVersion );
	}

	@SuppressWarnings(value = "unchecked")
	protected void validateBuildTimeArtifact(Artifact antlrArtifact, ArtifactVersion pluginAntlrVersion)
			throws MojoExecutionException {
		if ( antlrArtifact == null ) {
			validateMissingBuildtimeArtifact();
			return;
		}

		// otherwise, lets make sure they match...
		ArtifactVersion projectAntlrVersion = determineArtifactVersion( antlrArtifact );
		if ( pluginAntlrVersion.compareTo( projectAntlrVersion ) != 0 ) {
			getLog().warn(
					"Encountered " + ANTLR_GROUP_ID + ':' + ANTLR_ARTIFACT_NAME + ':' + projectAntlrVersion.toString() +
							" which did not match Antlr version used by plugin [" + pluginAntlrVersion.toString() + "]"
			);
		}
	}

	protected void validateMissingBuildtimeArtifact() {
		// generally speaking, its ok for the project to not define a dep on the build-time artifact...
	}

	@SuppressWarnings(value = "unchecked")
	protected void validateRunTimeArtifact(Artifact antlrRuntimeArtifact, ArtifactVersion pluginAntlrVersion)
			throws MojoExecutionException {
		if ( antlrRuntimeArtifact == null ) {
			// its possible, if the project instead depends on the build-time (or full) artifact.
			return;
		}

		ArtifactVersion projectAntlrVersion = determineArtifactVersion( antlrRuntimeArtifact );
		if ( pluginAntlrVersion.compareTo( projectAntlrVersion ) != 0 ) {
			getLog().warn(
					"Encountered " + ANTLR_GROUP_ID + ':' + ANTLR_RUNTIME_ARTIFACT_NAME + ':' + projectAntlrVersion.toString() +
							" which did not match Antlr version used by plugin [" + pluginAntlrVersion.toString() + "]"
			);
		}
	}

	/**
	 * Builds the classloader to pass to gUnit.
	 *
	 * @param antlrArtifact The plugin's (our) Antlr dependency artifact.
	 *
	 * @return The classloader for gUnit to use
	 *
	 * @throws MojoExecutionException Problem resolving artifacts to {@link java.net.URL urls}.
	 */
	private ClassLoader determineProjectCompileScopeClassLoader(Artifact antlrArtifact)
			throws MojoExecutionException {
		ArrayList<URL> classPathUrls = new ArrayList<URL>();
		getLog().info( "Adding Antlr artifact : " + antlrArtifact.getId() );
		classPathUrls.add( resolveLocalURL( antlrArtifact ) );

		for ( String path : classpathElements() ) {
			try {
				getLog().info( "Adding project compile classpath element : " + path );
				classPathUrls.add( new File( path ).toURI().toURL() );
			}
			catch ( MalformedURLException e ) {
				throw new MojoExecutionException( "Unable to build path URL [" + path + "]" );
			}
		}

		return new URLClassLoader( classPathUrls.toArray( new URL[classPathUrls.size()] ), getClass().getClassLoader() );
	}

	protected static URL resolveLocalURL(Artifact artifact) throws MojoExecutionException {
		try {
			return artifact.getFile().toURI().toURL();
		}
		catch ( MalformedURLException e ) {
			throw new MojoExecutionException( "Unable to resolve artifact url : " + artifact.getId(), e );
		}
	}

	@SuppressWarnings( "unchecked" )
	private List<String> classpathElements() throws MojoExecutionException {
		try {
			// todo : should we combine both compile and test scoped elements?
			return ( List<String> ) project.getTestClasspathElements();
		}
		catch ( DependencyResolutionRequiredException e ) {
			throw new MojoExecutionException( "Call to Project#getCompileClasspathElements required dependency resolution" );
		}
	}

	private void performExecution(ClassLoader projectCompileScopeClassLoader) throws MojoExecutionException {
		getLog().info( "gUnit report directory : " + reportDirectory.getAbsolutePath() );
		if ( !reportDirectory.exists() ) {
			boolean directoryCreated = reportDirectory.mkdirs();
			if ( !directoryCreated ) {
				getLog().warn( "mkdirs() reported problem creating report directory" );
			}
		}

		Result runningResults = new Result();
		ArrayList<String> failureNames = new ArrayList<String>();

		System.out.println();
		System.out.println( "-----------------------------------------------------------" );
		System.out.println( " G U N I T   R E S U L T S" );
		System.out.println( "-----------------------------------------------------------" );

		for ( File script : collectIncludedSourceGrammars() ) {
			final String scriptPath = script.getAbsolutePath();
			System.out.println( "Executing script " + scriptPath );
			try {
				String scriptBaseName = StringUtils.chompLast( FileUtils.basename( script.getName() ), "." );

				ANTLRFileStream antlrStream = new ANTLRFileStream( scriptPath );
				GrammarInfo grammarInfo = Interp.parse( antlrStream );
				gUnitExecutor executor = new gUnitExecutor(
						grammarInfo,
						projectCompileScopeClassLoader,
						script.getParentFile().getAbsolutePath()
				);

				String report = executor.execTest();
				writeReportFile( new File( reportDirectory, scriptBaseName + ".txt" ), report );

				Result testResult = new Result();
				testResult.tests = executor.numOfTest;
				testResult.failures = executor.numOfFailure;
				testResult.invalids = executor.numOfInvalidInput;

				System.out.println( testResult.render() );

				runningResults.add( testResult );
				for ( AbstractTest test : executor.failures ) {
					failureNames.add( scriptBaseName + "#" + test.getHeader() );
				}
			}
			catch ( IOException e ) {
				throw new MojoExecutionException( "Could not open specified script file", e );
			}
			catch ( RecognitionException e ) {
				throw new MojoExecutionException( "Could not parse gUnit script", e );
			}
		}

		System.out.println();
		System.out.println( "Summary :" );
		if ( ! failureNames.isEmpty() ) {
			System.out.println( "  Found " + failureNames.size() + " failures" );
			for ( String name : failureNames ) {
				System.out.println( "    - " + name );
			}
		}
		System.out.println( runningResults.render() );
		System.out.println();

		if ( runningResults.failures > 0 ) {
			throw new MojoExecutionException( "Found gUnit test failures" );
		}

		if ( runningResults.invalids > 0 ) {
			throw new MojoExecutionException( "Found invalid gUnit tests" );
		}
	}

	private Set<File> collectIncludedSourceGrammars() throws MojoExecutionException {
		SourceMapping mapping = new SuffixMapping( "g", Collections.EMPTY_SET );
        SourceInclusionScanner scan = new SimpleSourceInclusionScanner( getIncludePatterns(), getExcludePatterns() );
        scan.addSourceMapping( mapping );
		try {
			Set scanResults = scan.getIncludedSources( sourceDirectory, null );
			Set<File> results = new HashSet<File>();
			for ( Object result : scanResults ) {
				if ( result instanceof File ) {
					results.add( ( File ) result );
				}
				else if ( result instanceof String ) {
					results.add( new File( ( String ) result ) );
				}
				else {
					throw new MojoExecutionException( "Unexpected result type from scanning [" + result.getClass().getName() + "]" );
				}
			}
			return results;
		}
		catch ( InclusionScanException e ) {
			throw new MojoExecutionException( "Error determining gUnit sources", e );
		}
	}

	private void writeReportFile(File reportFile, String results) {
		try {
			Writer writer = new FileWriter( reportFile );
			writer = new BufferedWriter( writer );
			try {
				writer.write( results );
				writer.flush();
			}
			finally {
				try {
					writer.close();
				}
				catch ( IOException ignore ) {
				}
			}
		}
		catch ( IOException e ) {
			getLog().warn(  "Error writing gUnit report file", e );
		}
	}

	private static class Result {
		private int tests = 0;
		private int failures = 0;
		private int invalids = 0;

		public String render() {
			return String.format( "Tests run: %d,  Failures: %d,  Invalid: %d", tests, failures, invalids );
		}

		public void add(Result result) {
			this.tests += result.tests;
			this.failures += result.failures;
			this.invalids += result.invalids;
		}
	}

}
