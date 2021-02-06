Azure supports automated deployment directly from several sources. The following options are available:

Azure DevOps: You can push your code to Azure DevOps (previously known as Visual Studio Team Services), build your code in the cloud, run the tests, generate a release from the code, and finally, push your code to an Azure Web App.
GitHub: Azure supports automated deployment directly from GitHub. When you connect your GitHub repository to Azure for automated deployment, any changes you push to your production branch on GitHub will be automatically deployed for you.
Bitbucket: With its similarities to GitHub, you can configure an automated deployment with Bitbucket.
OneDrive: Microsoft's cloud-based storage. You must have a Microsoft Account linked to a OneDrive account to deploy to Azure.
Dropbox: Azure supports deployment from Dropbox, which is a popular cloud-based storage system that is similar to OneDrive.

Create deployment slots and tiers
Deployment slots are available only when your web app uses an App Service plan in the Standard, Premium, or Isolated tier. The following table shows the maximum number of slots you can create:

CREATE DEPLOYMENT SLOTS AND TIERS
Tier	Maximum staging slots
Free	0
Shared	0
Basic	0
Standard	5
Premium	20
Isolated	20

