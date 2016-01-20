---
title: "Deploying Databases With Octopus Deploy: Part 2"
date: 2014-06-10T08:00:00-05:00
comments: true
sharing: true
categories:categories: 
- Database
- Deployment
- Continuous Delivery
tags:
- Octopus Deploy
- Database
- Deployment
- .NET
- Continuous Delivery
- Entity Framework
---

Continuing with my series on deploying databases with Octopus Deploy, I want to cover an area that people commonly know is possible but often struggle with the details: Deploying with Entity Framework Migrations. 

Entity Framework Migrations are in concept simple. The EF team provides a great executable (migrate.exe) located in the tools folder of the NuGet package to perform the migration. Packaging it up can be a little more tricky.

<!-- more -->

## Project Setup ##
When creating your deployment package for Octopus, you're going to want to include the migrate.exe file. Since NuGet packages everything from the root of the project, you're going to need to provide the path to the file relative to the project root. You're also going to need the PowerShell script to run the executable and everything you have compiled for the project (in this case what's in the release directory). An example of this is in the MyApp.nuspec file below.

{{< include_code lang="xml" src="MyApp.nuspec" >}}

The Deploy.ps1 deployment script is fairly simple, the first several lines setup the paths to the executable and tooling. The last line, 18, is the one that does all the work. The first argument is the .dll that contains the migration scripts. You will want to change this for your project. The second argument (*/startUpConfigurationFile*) let's the tool know the application has a configuration file that should be respected. This can be necessary if you are trying to bootstrap things like the ASP.NET 1.0 Identity Provider... but that's for another post. The final arguments specify the target server and driver and that the system should do verbose logging. I've found this to be very helpful when debugging problems with deployment.

{{< include_code src="Deploy.ps1" >}}

## Deployment In Octopus ##
Building the deployment package in your CI server is simple. If you're using TeamCity, you can use [OctoPack](http://docs.octopusdeploy.com/display/OD/TeamCity) as part of the build, or I would suggest creating a [NuGet Package step](http://confluence.jetbrains.com/display/TCD8/NuGet+Pack) to package up the file. From there you create a publish step to push it to your local repository or the new Octopus Deploy package repository if you're using version 2.3 or later.

Once you have the deployment package, setting this up in Octopus is really straight forward. Create a new deployment step, I chose "Deploy Database". Select the deployment package, the role you setup earlier and Configuration Variables feature to transform any needed settings.

{{< figure src="/images/posts/DeployDatabaseProjectOctopusStep.png" >}}

Once you save that add a variable named *ConnectionString* to your deployment variables and set it for your environments. Once that's in place you should be able to deploy your EF database projects.
