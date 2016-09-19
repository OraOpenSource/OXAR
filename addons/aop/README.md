# APEX Office Print

[APEX Office Print](apexofficeprint.com) (AOP) is a flexible print solution for Oracle Application Express (APEX) to generate your Office (docx, xlsx, pptx) and PDF-documents in no time and effort.

AOP makes printing and exporting declarative through the AOP APEX-plugin. AOP also comes with a PL/SQL and REST API which makes AOP very flexible and powerful.

You create a template in Word, Excel or Powerpoint with some placeholder tags, you specify your data source (SQL, PL/SQL, REST, Classic or Interactive Report, ...) and AOP will merge both into one and sends you the output you requested.

You find the documentation [online](https://www.apexofficeprint.com/docs).

APEX Office Print (AOP) is a product of [APEX R&D](https://www.apexrnd.com).


## Configuration

The following options are modifiable for configuring AOP as part of AOP in [config.properties](/config.properties)

Name | Default | Description
--- | --- | ---
`OOS_AOP_YN` | `Y` | `Y` or `N`
`OOS_AOP_SCHEMA_NAME` | `AOP` |
`OOS_AOP_SCHEMA_PASS` | `aop` |
`OOS_AOP_APEX_WORKSPACE` | `AOP` |
`OOS_AOP_APEX_USER_NAME` | `AOP` |
`OOS_AOP_APEX_USER_PWD` | `aop` |

The script will create a schema and workspace, which will contain the AOP Sample application.
That application gives a good overview of the power of AOP, how to work with it and what to expect as output.


## Getting started

Login to the `OOS_AOP_APEX_WORKSPACE` workspace with the username and password you specified above.

Run the AOP Sample application.


## Using AOP in your own workspace and application

Go in a Terminal window to the directory OXAR/addons/aop and run:

` ./install_aop_cloud.sh your@email.com`

This will create an account on apexofficeprint.com and returns your API key which you will need to enter in the APEX-plugin (next step).

In your APEX application go to Shared Components > Plug-ins > and import the plugin process\_type\_plugin\_be\_apexrnd\_aop.sql which you find in the same directory as the previous script.

Finally, connect to your own workspace and go to SQL Workshop > SQL Scripts > Upload. Upload and run aop\_db\_pkg.sql which you find in the OXAR/addons/aop directory. This will create the AOP PL/SQL API which the APEX plugin will use behind the scenes.


## Running AOP local

If you want to run the server component on your own virtual machine instead of using your cloud version, go in a Terminal window to the directory OXAR/addons/aop and run:

` ./install_aop_local.sh your@email.com`

This will download and install the latest version of AOP on your machine.

TODO: add commands to start, restart and stop AOP (Martin)