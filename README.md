# gitflow-R
## This repository contains the GitHub actions to support the Continuous Integration and Continuous Deployment incorporated Branching Strategy (CI-CD-BS) for R package development. 

## Instruction to use this tool:
  1. Make sure your repository has the following branches:
    <br>&emsp;main
    <br>&emsp;dev
    <br>&emsp;release*
    <br>&emsp;feature*
    <br>&emsp;Conda_Package*
    <br>&emsp;github_page*
  3. Make a .github/workflows directory under your repo.
  4. Copy the gitflow-R-action.yml from the GitHub Actions folder into the .github/workflows directory if you want the automatic CI-CD-BS.
  5. Copy the Manual_Deployment_to_NIDAP.yml from the GitHub Actions folder into the .github/workflows directory if you want the manual deployment tool.
  6. Update the information at ' image_to_use: "<Replace with your image>" ' line in gitflow-R-action.yml to a GitHub container registry address for your Docker image.
  7. Update the information at ' uses: fnlcr-bids-sdsi/gitflow-R/.github/workflows/parser.yml@<Project Specific Branch> ' to the specific branch if you have any, or replace with your forked repo address.
  8. Make sure you have a stable conda recipe in "Conda_Recipe" folder.
  9. Make sure you have the repository setup to use github_page for GitHub page delpoyment.
  10. Make sure you have a working container ready to run the CI-CD, sure we can make the environment on the fly, but the time it will take is not optimum.
  11. Please reach out to us for the complete SOP as it contains some internal information. 
  12. If you want customed support for actions, please contact us.
 
