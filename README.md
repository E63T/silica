# silica

:warning: **EXPERIMENTAL** C++ hardware definition header generator using SVD files 

Also contains some useful headers for embedded development

## Usage

:warning: This section is incomplete

Create a file named `silica.json` inside a desired output folder (in this example, the output folder is `example`). Example follows.

```json
{
    "default_env" : "stm32f0x2",
    "envs" : {
        "stm32f0x2" : {
            "silica_version" : "~> 0.1.0",
            "input_file" : "STM32F0x2.svd",
            "features" : {
                "copy_includes" : false
            }
        }
    }
}
```

Then 

```bash
    crystal run ./src/silica.cr -- example
```

## Development

TODO:
* [x] Field support
  * [x] Field value enumerations
  * [x] Field masks 
  * [x] Field offsets
  * [x] Field widths
  * [x] Common values within a register (:warning: WIP)
* [ ] Helper methods
* [ ] Full `std::hardware` TR implementation
* [x] Doc generation (:warning: WIP) 
* [ ] Custom IRQ handlers
* [x] Configuration options (:warning: WIP)
  * [x] Feature support 
    * [x] Optionally turn off field widths, masks, offsets and common values
    * [x] Docs
    * [ ] Copy includes  
* [ ] Examples
* [ ] Tests
* [ ] Proper logging
* [ ] Fix C++ warnings
* [ ] Remove unnecessary XPaths
* [ ] Exception handling
* [ ] Peripheral groups support

## Contributing

1. Fork it (<https://github.com/unn4m3d/silica/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [unn4m3d](https://github.com/unn4m3d) - creator, maintainer
