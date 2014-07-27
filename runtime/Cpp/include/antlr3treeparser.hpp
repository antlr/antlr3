#ifndef	ANTLR3TREEPARSER_HPP
#define	ANTLR3TREEPARSER_HPP

// [The "BSD licence"]
// Copyright (c) 2005-2009 Gokulakannan Somasundaram, ElectronDB

//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include    "antlr3defs.hpp"

/** Internal structure representing an element in a hash bucket.
 *  Stores the original key so that duplicate keys can be rejected
 *  if necessary, and contains function can be supported If the hash key
 *  could be unique I would have invented the perfect compression algorithm ;-)
 */
ANTLR_BEGIN_NAMESPACE()

template<class ImplTraits>
class	TreeParser : public ImplTraits::template RecognizerType< TreeParser<ImplTraits> >
{
public:
	typedef typename ImplTraits::TreeNodeStreamType TreeNodeStreamType;
	typedef TreeNodeStreamType StreamType;
	typedef typename TreeNodeStreamType::IntStreamType IntStreamType;
	typedef typename ImplTraits::TreeType TreeType;
	typedef TreeType TokenType;
	typedef typename ImplTraits::template ExceptionBase<TreeNodeStreamType> ExceptionBaseType;
	typedef typename ImplTraits::template RecognizerType< TreeParser<ImplTraits> > RecognizerType;
	typedef typename RecognizerType::RecognizerSharedStateType RecognizerSharedStateType;
	typedef Empty TokenSourceType;
	typedef typename ImplTraits::BitsetListType BitsetListType;
	typedef typename ImplTraits::StringType StringType;
	typedef typename ImplTraits::CommonTokenType CommonTokenType;

private:
    /** Pointer to the common tree node stream for the parser
     */
    TreeNodeStreamType*		m_ctnstream;

public:
	TreeParser( ANTLR_UINT32 sizeHint, TreeNodeStreamType* ctnstream,
											RecognizerSharedStateType* state);
	TreeNodeStreamType* get_ctnstream() const;
	IntStreamType* get_istream() const;
	RecognizerType* get_rec();

	//same as above. Just that get_istream exists for lexer, parser, treeparser
	//get_parser_istream exists only for parser, treeparser. So use it accordingly
	IntStreamType* get_parser_istream() const;

    /** Set the input stream and reset the parser
     */
    void	setTreeNodeStream(TreeNodeStreamType* input);

    /** Return a pointer to the input stream
     */
    TreeNodeStreamType* getTreeNodeStream();

	TokenType*	getMissingSymbol( IntStreamType* istream,
										  ExceptionBaseType*		e,
										  ANTLR_UINT32			expectedTokenType,
										  BitsetListType*	follow);

    /** Pointer to a function that knows how to free resources of an ANTLR3 tree parser.
     */
	~TreeParser();

	void fillExceptionData( ExceptionBaseType* ex );
	void displayRecognitionError( ANTLR_UINT8** tokenNames, ExceptionBaseType* ex );
	void exConstruct();
	void mismatch(ANTLR_UINT32 ttype, BitsetListType* follow);
};

ANTLR_END_NAMESPACE()

#include "antlr3treeparser.inl"

#endif
