---
title: "Deploying databases with Octopus Deploy Part 3"
date: 2014-09-06T15:00:00-05:00
comments: true
sharing: true
categories: 
- Database
- Deployment
- Continuous Delivery
tags:
- Octopus Deploy
- Database
- Deployment
- .NET
- Continuous Delivery
---

Completing my series on deploying databases with Octopus Deploy, I want to cover how to deal with a common gap when working with SQL Database Projects and SQL Server Data Tools (SSDT): seeding data into the database. 

Most people deal with this by using PostDeployment SQL scripts that do merge queries to insert or update the data. While this technique works, the data isn't very readable and can be difficult to maintain as the data set or number of tables grow. It can also be difficult to work around foreign key constraints to make sure data is loaded in the correct order. Allow me to present an alternative... 

<!-- more -->

## Introducing DatabaseDataLoader ##
I created a simple, open source utility to simplify the problem. The tool is based on using CSV files which can be easily maintained both in a text editor and tools like Microsoft Excel. The file name should match the table being loaded. So if I'm loading a table named _Accounts_ then the file should be _Accounts.csv_.

You can download the latest version of the tool here: [https://github.com/dpiessens/DatabaseDataLoader/releases](https://github.com/dpiessens/DatabaseDataLoader/releases)

The folder structure dictates how things should be loaded. A top level folder groups the type of data. I like to use "base" for the core data, then a folder for each environment to hold things like test data. Inside those folders should be two additional folders: InsertOnly and Updateable. Files in InsertOnly will be checked by primary key and if the record exists it will be skipped. Files in Updateable will get inserted or updated on each run. Here's an example structure:

{{< img src="FileStructure.png" >}}

To run the loader simply call the executable with a connection string and a base path similar to this:

`
DatabaseDataLoader.exe -baseDir <baseDirectory> -connection <connectionString>
`

The _connection_ argument should be a .NET connection string to the database that is loaded. The _baseDir_ argument specifies the base directory to load data from. From the sample above, it would either be the full path to _base_ or _QA_.

The tool makes it easy to edit data, update it and load it in. Nothing special really needs to be done to the CSV files, the main idea is that data is loaded with the database constraints disabled so that ordering, hierarchy etc. do not need to be maintained. The tool reflects the actual database schema and does all the appropriate data conversions so data is validated on insert and failures will be reflected for all lines that don't load correctly.

## Using the loader with a database deploy ##

Similar to [Part 2]({{< relref "deploying-databases-with-octopus-deploy-part-2.md" >}}), you will need a Deploy.ps1 file, but this one will load the data in addition to deploying any schema update. The additional scripting will load the base data first, then look at the target environment name and look for a matching directory. If it finds that it will do the load on that directory as well. A sample file looks like this: 

{{< include_code src="Deploy.ps1" >}}

Notice that the tooling expects that DatabaseDataLoader.exe is packed up with the rest of the deployment, so it should be checked into your database project. Normally I would do this as a NuGet package, but database projects don't support NuGet at this point. Also I added a global variable called _$SkipDataLoad_ so you can disable it if you need to for any reason during the deployment process.

Hopefully you've found this series helpful with deploying databases, until next time, keep pushing to production!