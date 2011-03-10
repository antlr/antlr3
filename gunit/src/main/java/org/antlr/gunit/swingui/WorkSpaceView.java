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
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.antlr.gunit.swingui;

import org.antlr.gunit.swingui.ImageFactory;
import java.awt.*;
import javax.swing.*;

/**
 *
 * @author scai
 */
public class WorkSpaceView extends JFrame {

    protected JSplitPane splitListClient ;
    protected JTabbedPane tabEditors;
    protected JPanel paneToolBar;
    protected StatusBarController paneStatus;
    protected TestCaseEditController paneEditor;
    protected JToolBar toolbar;
    protected JTextArea txtEditor;
    protected RuleListController listRules;
    protected JMenuBar menuBar;
    protected JScrollPane scrollCode;
    protected JPanel resultPane;

    protected JButton btnOpenGrammar;

    public WorkSpaceView() {
        super();
    }

    protected void initComponents() {

        this.paneEditor = new TestCaseEditController(this);
        this.paneStatus = new StatusBarController();

        this.toolbar = new JToolBar();
        this.toolbar.setBorder(BorderFactory.createEmptyBorder());
        this.toolbar.setFloatable(false);
        this.toolbar.setBorder(BorderFactory.createEmptyBorder());

        this.txtEditor = new JTextArea();
        this.txtEditor.setLineWrap(false);
        this.txtEditor.setFont(new Font("Courier New", Font.PLAIN, 13));
        this.scrollCode = new JScrollPane(txtEditor,
                JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
                JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        this.scrollCode.setBorder(BorderFactory.createLineBorder(Color.LIGHT_GRAY));

        this.tabEditors = new JTabbedPane();
        this.tabEditors.addTab("Case Editor", ImageFactory.getSingleton().TEXTFILE16, this.paneEditor.getView());
        this.tabEditors.addTab("Script Source", ImageFactory.getSingleton().WINDOW16, this.scrollCode);

        this.listRules = new RuleListController();

        this.splitListClient = new JSplitPane( JSplitPane.HORIZONTAL_SPLIT,
                this.listRules.getView(), this.tabEditors);
        this.splitListClient.setResizeWeight(0.4);
        this.splitListClient.setBorder(BorderFactory.createEmptyBorder());


        
        this.getContentPane().add(this.toolbar, BorderLayout.NORTH);
        this.getContentPane().add(this.splitListClient, BorderLayout.CENTER);
        this.getContentPane().add(this.paneStatus.getView(), BorderLayout.SOUTH);

        // self
        this.setPreferredSize(new Dimension(900, 500));
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

}
