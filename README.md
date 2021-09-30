# silica

:warning: **EXPERIMENTAL** C++ hardware definition header generator using SVD files 

## Usage

```bash
    cat example/STM32F0x2.svd | crystal ./silica.cr > example/test.hpp
```

## Development

TODO:
* [ ] Field support
* [ ] Helper methods
* [ ] Full `std::hardware` TR implementation
* [ ] Doc generation
* [ ] Custom IRQ handlers
* [ ] Configuration options
* [ ] Examples

## Contributing

1. Fork it (<https://github.com/unn4m3d/silica/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [unn4m3d](https://github.com/unn4m3d) - creator, maintainer
