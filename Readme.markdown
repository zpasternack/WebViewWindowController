### WebViewWindowController ###

An `NSWindowController` subclass which includes a `WebView`. This makes it very easy to put styled content
into a window, say, for an About Box. It does a couple neat tricks, as well:
* It catches clicks on hyperlinks and opens them in the default browser (because showing them there in your about box is almost certainly not what you want).
* It adapts for Mojave Dark Mode.

![Screenshot: Light Mode](screenshot-light.png)
![Screenshot: Dark Mode](screenshot-dark.png)


### Usage ###

Create an instance of `WebViewWindowController` (or a subclass thereof) the same way you would any
`NSWindowController`-derived class. See `AboutBoxController.swift` in this project for an example. 

If you setup your interface in Interface Builder (which I recommend), you'll need to setup a few things:
* Set the `webView` IBOutlet to the web view
* Set the `htmlFile` property to the name of the html file to load (which should be located in the main bundle)
* Set `adaptsForDarkMode` to false if you don't want `WebViewWindowController` to adapt your content for Dark Mode.


### Other Info ###

`WebViewWindowController` is written in Swift 4.2.

By default, it uses the (now deprecated) `WebView` class. If you the compile flag `OPT_USE_WKWEBVIEW`, it will 
instead use the new `WKWebView`. I have not tested this option much, and none of my shipping apps use it yet.

Dark Mode adaptation is achieved by injecting some CSS into the head of your html (via Javascript calls). See
`modify(forAppearance:)` to see how that works and/or modify the behavior.

### Who's responsible for this? ###

I'm Zacharias Pasternack, lead developer for [Fat Apps, LLC](http://www.fat-apps.com). You can check 
out [my blog](http://zpasternack.org), or follow me on [Twitter](https://twitter.com/zpasternack).


### License ###

The code is provided under a Modified BSD License. See the LICENSE file for more info.
