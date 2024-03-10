#!/bin/bash

project_dir="HelloWorldFunction"
root_dir=$(pwd)

cd .aws-sam/build/$project_dir
zip -vr "$project_dir.zip" ./*
cd $root_dir
mv ".aws-sam/build/$project_dir/$project_dir.zip" .

