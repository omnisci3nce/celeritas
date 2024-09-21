# Celeritas

## Design Goals

## Feature Goals

## Creating a project
### Windows
1. Run the GenerateProject.bat script and input the project name, this can be an argument or as an input
2. The script will create a project folder with the name of the project and have a main odin file and build scripts
3. Run BuildWindows.bat for odin build, RunWindows.bat for odin run

## Coding Style

*These can be movied into a CONTRIBUTING.md or something later on*

#### RAL

- **`Desc` suffix** refers to a description of a resource that you pass to a function that then creates the resource
- **`Info` suffix** represents a chunk of data that describes how a draw call or graphics call will be made, but is not related to a resource that is created - it only refers to that call in that frame. 