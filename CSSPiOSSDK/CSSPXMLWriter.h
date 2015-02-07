//
//  CSSPXMLWriter.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/7.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>

// xml stream writer
@protocol CSSPXMLStreamWriter

- (void) writeStartDocument;
- (void) writeStartDocumentWithVersion:(NSString*)version;
- (void) writeStartDocumentWithEncodingAndVersion:(NSString*)encoding version:(NSString*)version;

- (void) writeStartElement:(NSString *)localName;

- (void) writeEndElement; // automatic end element (mirrors previous start element at the same level)
- (void) writeEndElement:(NSString *)localName;

- (void) writeEmptyElement:(NSString *)localName;

- (void) writeEndDocument; // write any remaining end elements

- (void) writeAttribute:(NSString *)localName value:(NSString *)value;

- (void) writeCharacters:(NSString*)text;
- (void) writeComment:(NSString*)comment;
- (void) writeProcessingInstruction:(NSString*)target data:(NSString*)data;
- (void) writeCData:(NSString*)cdata;

// return the written xml string buffer
- (NSMutableString*) toString;
// return the written xml as data, set to the encoding used in the writeStartDocumentWithEncodingAndVersion method (UTF-8 per default)
- (NSData*) toData;

// flush the buffers, if any
- (void) flush;
// close the writer and buffers, if any
- (void) close;

@end

// xml stream writer with namespace support
@protocol CSSPNSXMLStreamWriter <CSSPXMLStreamWriter>

- (void) writeStartElementWithNamespace:(NSString *)namespaceURI localName:(NSString *)localName;
- (void) writeEndElementWithNamespace:(NSString *)namespaceURI localName:(NSString *)localName;
- (void) writeEmptyElementWithNamespace:(NSString *)namespaceURI localName:(NSString *)localName;

- (void) writeAttributeWithNamespace:(NSString *)namespaceURI localName:(NSString *)localName value:(NSString *)value;

// set a namespace and prefix
- (void)setPrefix:(NSString*)prefix namespaceURI:(NSString *)namespaceURI;
// write (and set) a namespace and prefix
- (void) writeNamespace:(NSString*)prefix namespaceURI:(NSString *)namespaceURI;

// set the default namespace (empty prefix)
- (void)setDefaultNamespace:(NSString*)namespaceURI;
// write (and set) the default namespace
- (void) writeDefaultNamespace:(NSString*)namespaceURI;

- (NSString*)getPrefix:(NSString*)namespaceURI;
- (NSString*)getNamespaceURI:(NSString*)prefix;

@end

@interface CSSPXMLWriter : NSObject <CSSPNSXMLStreamWriter> {
    
    // the current output buffer
    NSMutableString* writer;
    
    // the target encoding
    NSString* encoding;
    
    // the number current levels
    int level;
    // is the element open, i.e. the end bracket has not been written yet
    BOOL openElement;
    // does the element contain characters, cdata, comments
    BOOL emptyElement;
    
    // the element stack. one per element level
    NSMutableArray* elementLocalNames;
    NSMutableArray* elementNamespaceURIs;
    
    // the namespace array. zero or more namespace attributes can be defined per element level
    NSMutableArray* namespaceURIs;
    // the namespace count. one per element level
    NSMutableArray* namespaceCounts;
    // the namespaces which have been written to the stream
    NSMutableArray* namespaceWritten;
    
    // mapping of namespace URI to prefix and visa versa. Corresponds in size to the namespaceURIs array.
    NSMutableDictionary* namespaceURIPrefixMap;
    NSMutableDictionary* prefixNamespaceURIMap;
    
    // tag indentation
    NSString* indentation;
    // line break
    NSString* lineBreak;
    
    // if true, then write elements without children as <start /> instead of <start></start>
    BOOL automaticEmptyElements;
}

@property (nonatomic, strong, readwrite) NSString* indentation;
@property (nonatomic, strong, readwrite) NSString* lineBreak;
@property (nonatomic, assign, readwrite) BOOL automaticEmptyElements;
@property (nonatomic, readonly) int level;

// helpful for formatting, special needs
// write linebreak, if any
- (void) writeLinebreak;
// write indentation, if any
- (void) writeIndentation;
// write end of start element, so that the start tag is complete
- (void) writeCloseStartElement;

// write any outstanding namespace declaration attributes in a start element
- (void) writeNamespaceAttributes;
// write escaped text to the stream
- (void) writeEscape:(NSString*)value;
// wrote unescaped text to the stream
- (void) write:(NSString*)value;

@end