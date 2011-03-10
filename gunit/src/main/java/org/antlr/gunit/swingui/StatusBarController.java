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

import java.awt.Dimension;
import java.awt.FlowLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;

public class StatusBarController implements IController {

    private final JPanel panel = new JPanel();

    private final JLabel labelText = new JLabel("Ready");
    private final JLabel labelRuleName = new JLabel("");
    private final JProgressBar progress = new JProgressBar();
    
    public StatusBarController() {
        initComponents();
    }

    private void initComponents() {
        labelText.setPreferredSize(new Dimension(300, 20));
        labelText.setHorizontalTextPosition(JLabel.LEFT);
        progress.setPreferredSize(new Dimension(100, 15));

        final JLabel labRuleHint = new JLabel("Rule: ");

        FlowLayout layout = new FlowLayout();
        layout.setAlignment(FlowLayout.LEFT);
        panel.setLayout(layout);
        panel.add(labelText);
        panel.add(progress);
        panel.add(labRuleHint);
        panel.add(labelRuleName);
        panel.setOpaque(false);
        panel.setBorder(javax.swing.BorderFactory.createEmptyBorder());

    }

    public void setText(String text) {
        labelText.setText(text);
    }

    public void setRule(String name) {
        this.labelRuleName.setText(name);
    }

    public Object getModel() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public JPanel getView() {
        return panel;
    }

    public void setProgressIndetermined(boolean value) {
        this.progress.setIndeterminate(value);
    }
    
    public void setProgress(int value) {
        this.progress.setIndeterminate(false);
        this.progress.setValue(value);
    }


}
