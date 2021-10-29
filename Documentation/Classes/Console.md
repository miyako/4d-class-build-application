<!-- Class to print 'Compile project' status to the CLI -->
# Console

Class to print `Compile project` status to the CLI. Invokes `LOG EVENT`.

Intended scenario: 

* Log events in headless mode.

## Usage

```4d
$status:=Compile project($project; $options)

var $console : cs.Console

$console:=cs.Console.new($project)

$console.printErrors($status)
```
