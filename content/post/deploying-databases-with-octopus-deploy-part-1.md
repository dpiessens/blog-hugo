---
title: "Deploying Databases with Octopus Deploy: Part 1"
date: 2014-05-20T15:00:55-05:00
comments: true
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

One of the most common questions I get when helping people with Continuous Delivery is how to I push updates to my database? The traditional mindset is often create a folder of SQL scripts and make the deployment push the newest ones. The problem that often arises from this is there's no rollback and things often get missed. There's got to be a better way! Assuming your organization is (or will become) comfortable with tooling doing your updates, there's some great options you have. 

I want to use the next three posts to describe the 3 most common SQL deployment problems:

- .NET Database Projects (this post)
- Entity Framework Code First
- Seeding Data in Database Projects

I'm going to use [Octopus Deploy](http://www.octopusdeploy.com "Octopus Deploy") to demo how you can deploy this, but assuming you use a deployment tool that has a packaging concept you can use this in any deployment tool.

<!-- more -->

## Project Setup ##
The assumption here is that you've created a [SQL Database Project](http://msdn.microsoft.com/en-us/library/hh272702.aspx "SQL Database Project"). If you haven't follow the link for instructions on how to create one. Once you have a project created, we'll need to add the information for our CI server to package up the project. To do this there's two things you'll need: A packaging manifest (in this case a NuGet package) and a helper script to do the actual deployment.

To put together the manifest add a NuGet package that looks like the snippet below. In this case make sure you replace the *title* and *name* tags from MyApplication to your application name.

{{< include_code lang="xml" src="ProjectPackage.nuspec" >}}

A few things to note about the packaging: The main output from the project (assuming you use release mode) is the bin directory. It should contain everything you need to use to deploy the project. Additionally there's the *DeploymentSetting.publish.xml* file. This is the settings file you can define as part of the project to indicate what the project should do on deploy. A lot of people miss this file and it really impacts the deployment from critical scenarios. One simple example when a column could result in a data loss; you may want to allow or deny it. Most people allow it but you need to specify it in this file. Finally there's the *Deploy.ps1* file. This is the file that takes care of the actual deployment. 

The Deploy.ps1 file is what does most of the magic. The script is really straight forward, it first checks to see if you have a variable named *ConnectionString*. Since that is needed to point at the database you want to deploy to, we fail if it doesn't exist. Next, we get the other things we need to deploy. We get the content directory that we specified in the NuGet file and find the .dacpac file that the CI server will create from the project. We'll also get the publish settings file. The final path looks for SQL Server Data Tools to do the deployment, the next section will discuss that setup. I've included some output lines to write that path information. Finally the last line if the file performs the publish to the target server. It pipes the output to a `Write-Host` command so it logs any output while it's running.

{{< include_code src="Deploy.ps1" >}}

## SQL Server Setup ##

In order to do the deployment we need to get the [SQL Server Data Tools](http://www.microsoft.com/en-us/download/details.aspx?id=38818) executable The link is for 2012, but you can easily find the tool for different versions of SQL. Unforunately this tool is too extensive to package with the deploy so we'll need to install it on the server doing the deployment.

If you haven't done so already you'll want to setup an [Octopus Tentacle agent](http://docs.octopusdeploy.com/display/OD/Installing+Tentacles) and have it run under a windows account that has the set of permissions you need for deployment. This way, you don't need to specify credentials in the connection string and only valid deployments can update the database. Make sure to register the agent with the main server and give it a database deployment role.

## Deployment In Octopus ##
Building the deployment package in your CI server is simple. If you're using TeamCity, you can use [OctoPack](http://docs.octopusdeploy.com/display/OD/TeamCity) as part of the build, or I would suggest creating a [NuGet Package step](http://confluence.jetbrains.com/display/TCD8/NuGet+Pack) to package up the file. From there you create a publish step to push it to your local repository or the new Octopus Deploy package repository if you're using version 2.3 or later.

Once you have the deployment package, setting this up in Octopus is really straight forward. Create a new deployment step, I chose "Deploy Database". Select the deployment package, the role you setup earlier and Configuration Variables feature to transform any needed settings.

{{< img src="DeployDatabaseProjectOctopusStep.png" >}}

Once you save that add a variable named *ConnectionString* to your deployment variables and set it for your environments. Once that's in place you should be able to deploy your SQL database projects!