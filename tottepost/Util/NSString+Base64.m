//
//  NSString+Base64.m
//  HudsonGrowl
//
//  Created by Benjamin Broll on 02.05.10.
//	The code was created based on
//  http://www.davidpires.com/blog/archives/basic-http-authentication-using-cocoa
//
//  This source code is licensed under the terms of the BSD license.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
//  ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSString+Base64.h"

#import "base64.h"


@implementation NSString (Base64)

- (NSString*) base64Encoding {
	const char *inputString = [self UTF8String];
    char *encodedString;
    base64_encode(inputString, strlen(inputString), &encodedString);
    
    NSString *retval = [NSString stringWithUTF8String:encodedString];
    free(encodedString);
    return retval;
}

@end
