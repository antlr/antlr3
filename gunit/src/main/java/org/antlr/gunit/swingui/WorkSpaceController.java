/*
 [The "BSD licence"]
 Copyright (c) 2009 Shaoting Cai
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package org.antlr.gunit.swingui;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.antlr.gunit.swingui.runner.gUnitAdapter;
import java.awt.*;
import java.io.IOException;
import org.antlr.gunit.swingui.model.*;
import org.antlr.gunit.swingui.ImageFactory;
import java.awt.event.*;
import java.io.File;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.filechooser.FileFilter;

/**
 *
 * @author scai
 */
public class WorkSpaceController implements IController{

    /* MODEL */
    private TestSuite currentTestSuite;
    private String testSuiteFileName = null;    // path + file

    /* VIEW */
    private final WorkSpaceView view = new WorkSpaceView();

    /* SUB-CONTROL */
    private final RunnerController runner = new RunnerController();

    public WorkSpaceController() {
        view.resultPane = (JPanel) runner.getView();
        view.initComponents();
        this.initEventHandlers();
        this.initToolbar();
    }

    public void show() {
        this.view.setTitle("gUnitEditor");
        this.view.setVisible(true);
        this.view.pack();
    }

    public Component getEmbeddedView() {
        return view.paneEditor.getView();
    }

    private void initEventHandlers() {
        this.view.tabEditors.addChangeListener(new TabChangeListener());
        this.view.listRules.setListSelectionListener(new RuleListSelectionListener());
        this.view.paneEditor.onTestCaseNumberChange = new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                view.listRules.getView().updateUI();
            }
        };
    }

    private void OnCreateTest() {
        JFileChooser jfc = new JFileChooser();
        jfc.setDialogTitle("Create test suite from grammar");
        jfc.setDialogType(JFileChooser.OPEN_DIALOG);
        jfc.setFileFilter(new FileFilter() {
            @Override
            public boolean accept(File f) {
                return f.isDirectory() || f.getName().toLowerCase().endsWith(TestSuiteFactory.GRAMMAR_EXT);
            }

            @Override
            public String getDescription() {
                return "ANTLR grammar file (*.g)";
            }
        });        
        if( jfc.showOpenDialog(view) != JFileChooser.APPROVE_OPTION ) return;

        view.paneStatus.setProgressIndetermined(true);
        final File grammarFile = jfc.getSelectedFile();

        currentTestSuite = TestSuiteFactory.createTestSuite(grammarFile);

        view.listRules.initialize(currentTestSuite);
        view.tabEditors.setSelectedIndex(0);
        view.paneStatus.setText("Grammar: " + currentTestSuite.getGrammarName());
        view.paneStatus.setProgressIndetermined(false);

        testSuiteFileName = null;
    }

    private void OnSaveTest() {
        TestSuiteFactory.saveTestSuite(currentTestSuite);
        JOptionPane.showMessageDialog(view, "Testsuite saved to:\n" + currentTestSuite.getTestSuiteFile().getAbsolutePath());
    }

    private void OnOpenTest()  {

        JFileChooser jfc = new JFileChooser();
        jfc.setDialogTitle("Open existing gUnit test suite");
        jfc.setDialogType(JFileChooser.OPEN_DIALOG);
        jfc.setFileFilter(new FileFilter() {

            @Override
            public boolean accept(File f) {
                return f.isDirectory() || f.getName().toLowerCase().endsWith(TestSuiteFactory.TEST_SUITE_EXT);
            }

            @Override
            public String getDescription() {
                return "ANTLR unit test file (*.gunit)";
            }
        });
        if( jfc.showOpenDialog(view) != JFileChooser.APPROVE_OPTION ) return;

        final File testSuiteFile = jfc.getSelectedFile();
        try {
            testSuiteFileName = testSuiteFile.getCanonicalPath();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        view.paneStatus.setProgressIndetermined(true);

        currentTestSuite = TestSuiteFactory.loadTestSuite(testSuiteFile);
        view.listRules.initialize(currentTestSuite);
        view.paneStatus.setText(currentTestSuite.getGrammarName());
        view.tabEditors.setSelectedIndex(0);

        view.paneStatus.setProgressIndetermined(false);
    }

    private void OnSelectRule(Rule rule) {
        if(rule == null) throw new IllegalArgumentException("Null");
        this.view.paneEditor.OnLoadRule(rule);
        this.view.paneStatus.setRule(rule.getName());

        // run result
        this.runner.OnShowRuleResult(rule);
    }

    private void OnSelectTextPane() {
        Thread worker = new Thread () {
            @Override
            public void run() {
                view.paneStatus.setProgressIndetermined(true);
                view.txtEditor.setText(
                    TestSuiteFactory.getScript(currentTestSuite));
                view.paneStatus.setProgressIndetermined(false);
            }
        };

        worker.start();
    }

    private void OnRunTest() {
        // save before run
        TestSuiteFactory.saveTestSuite(currentTestSuite);

        // run
        try {
            final gUnitAdapter adapter = new gUnitAdapter(currentTestSuite);
            if(currentTestSuite == null) return;
            adapter.run();
            
            runner.OnShowSuiteResult(currentTestSuite);
            view.tabEditors.addTab("Test Result", ImageFactory.getSingleton().FILE16, runner.getView());
            view.tabEditors.setSelectedComponent(runner.getView());
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(view, "Fail to run test:\n" + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        } 

    }

    private void initToolbar() {
        view.toolbar.add(new JButton(new CreateAction()));
        view.toolbar.add(new JButton(new OpenAction()));
        view.toolbar.add(new JButton(new SaveAction()));
        view.toolbar.add(new JButton(new RunAction()));

    }

    public Object getModel() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public Component getView() {
        return view;
    }


    /** Event handler for rule list selection. */
    private class RuleListSelectionListener implements ListSelectionListener {
        public void valueChanged(ListSelectionEvent event) {
            if(event.getValueIsAdjusting()) return;
            final JList list = (JList) event.getSource();
            final Rule rule = (Rule) list.getSelectedValue();
            if(rule != null) OnSelectRule(rule);
        }
    }


    /** Event handler for switching between editor view and script view. */
    public class TabChangeListener implements ChangeListener {
        public void stateChanged(ChangeEvent evt) {
            if(view.tabEditors.getSelectedIndex() == 1) {
                OnSelectTextPane();
            }
        }
        
    }
    

    /** Create test suite action. */
    private class CreateAction extends AbstractAction {
        public CreateAction() {
            super("Create", ImageFactory.getSingleton().ADDFILE);
            putValue(SHORT_DESCRIPTION, "Create a test suite from an ANTLR grammar");
        }
        public void actionPerformed(ActionEvent e) {
            OnCreateTest();
        }
    }


    /** Save test suite action. */
    private class SaveAction extends AbstractAction {
        public SaveAction() {
            super("Save", ImageFactory.getSingleton().SAVE);
            putValue(SHORT_DESCRIPTION, "Save the test suite");
        }
        public void actionPerformed(ActionEvent e) {
            OnSaveTest();
        }
    }


    /** Open test suite action. */
    private class OpenAction extends AbstractAction {
        public OpenAction() {
            super("Open", ImageFactory.getSingleton().OPEN);
            putValue(SHORT_DESCRIPTION, "Open an existing test suite");
            putValue(ACCELERATOR_KEY, KeyStroke.getKeyStroke(
                    KeyEvent.VK_O, InputEvent.CTRL_MASK));
        }
        public void actionPerformed(ActionEvent e) {
            OnOpenTest();
        }
    }

    /** Run test suite action. */
    private class RunAction extends AbstractAction {
        public RunAction() {
            super("Run", ImageFactory.getSingleton().NEXT);
            putValue(SHORT_DESCRIPTION, "Run the current test suite");
            putValue(ACCELERATOR_KEY, KeyStroke.getKeyStroke(
                    KeyEvent.VK_R, InputEvent.CTRL_MASK));
        }
        public void actionPerformed(ActionEvent e) {
            OnRunTest();
        }
    }
}
