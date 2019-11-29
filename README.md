#### Merci :bow: :heart:

Give thanks (in the form of github stars) to your fellow Rubyist.
Inspired by [cargo thanks](https://github.com/softprops/cargo-thanks) from [Doug](https://github.com/softprops) which was inspired in part by medium's clapping button as a way to show thanks for someone elses work you've found enjoyment in.

### Installation

```sh
cd ~ && bundle plugin install merci
```
(Moving to your user folder makes the plugin to be available globally and not only for a single project)

### Usage

```sh
bundle merci
```

### What does it do

`bundle merci` will gather all the direct dependencies (not the traversal ones) listed in your Gemfile and Star the project on GitHub.

### Limitation

- Only project hosted on GitHub are supported (Will be happy to have someone implement other VCS providers).
- If a gem doesn't specify where to find its source, we can't star it.
