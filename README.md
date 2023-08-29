# gitflow-R
## This repository contains the GitHub actions to support the Continuous Integration and Continuous Deployment incorporated Branching Strategy (CI-CD-BS) for R package development. 

## Instruction to use this tool:
  1. Make sure your repository has the following branches:
    <br>&emsp;main
    <br>&emsp;dev
    <br>&emsp;release*
    <br>&emsp;feature*
  2. Make a .github/workflows directory under your repo.
  3. Copy the gitflow-R-action.yml from the GitHub Actions folder into the .github/workflows directory if you want the automatic CI-CD-BS.
  4. Copy the Manual_Deployment_to_NIDAP.yml from the GitHub Actions folder into the .github/workflows directory if you want the manual deployment tool.
  5. Update the information at ' image_to_use: "<Replace with your image>" ' line in gitflow-R-action.yml to a GitHub container registry address for your Docker image.
  6. Update the information at ' uses: fnlcr-bids-sdsi/gitflow-R/.github/workflows/parser.yml@<Project Specific Branch> ' to the specific branch if you have any, or replace with your forked repo address.
  7. If you want customed support for actions, please contact us.
 
