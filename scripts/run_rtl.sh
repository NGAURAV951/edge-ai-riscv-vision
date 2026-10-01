#!/usr/bin/env bash
set -e
mkdir -p build
iverilog -g2012 -o build/dot_product_tb rtl/dot_product.s rtl/tb_dot_product.s
vvp build/dot_product_tb
