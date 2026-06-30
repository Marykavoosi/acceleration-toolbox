# GitHub & Version Control

In this workshop, we will use GitHub to collaborate on building a bioinformatics pipeline. GitHub is a platform for version control, which allows multiple people to work on the same project, track changes, and manage contributions efficiently.

## 0. Before the Workshop

Please make sure you:

- [Register for a GitHub account](https://github.com/signup)
- [Familiarize yourself with the interface](https://docs.github.com/en/get-started/quickstart) (optional but helpful)
- [Explore the workshop repository](https://github.com/HCEMM/acceleration-toolbox)

## 1. The Version Control System

One of the Scientific Computing tutorials explains the main concepts of version control, go [take a look](https://github.com/HCEMM/sc-tutorials/blob/main/github_tutorial/README.md).

## 2. Working on your own repository

For many cases, GitHub will not be used for collaboration, but rather as a platform to share your work and projects. As the sole contributor of a project, you still benefit from using GitHub to track changes, manage versions, and share your work with others.

On this section, you will set up your profile page on GitHub. This profile will be visible to people visiting `github.com/<your-github-username>`, and it is a great way to link to your research and projects (e.g., [the author's profile](https://github.com/iquasere)). 

Let's begin by [creating a new repository](https://github.com/new):
- Name your repository same as your GitHub username;
- Add a description (optional);
- Choose to make the repository public;
- Initialize the repository with a README file;
- Everything else is ignorable, but will be explained further ahead. Just leave as is.

GitHub offers multiple ways to interact with your repository: "Add file", ✏️ to edit files directly, simple navigation, etc. For every change you make, however, the Version Control system has to be followed. As such, once you make your changes, you will need to "commit" them, with a commit message. "add" and "push" will be automatic.

A template README file is available [here](https://github.com/HCEMM/acceleration-toolbox/blob/main/README_template.md). Either copy and paste the content, or download the file and upload it to your repository. This README file contains multiple sections that you can fill in with your information, such as your research interests, projects, and contact information. Feel free to customize it as you see fit!

### 2.1. GitHub Pages

[GitHub Pages](https://docs.github.com/en/pages) allows to display a website directly from your repository, and can be deployed from an HTML or a Markdown file.

Steps to generate your recently created profile in a webpage:
1. Create the `.github/workflows` folder on your repository;
2. Create the `website.yml` file with the contents of [our repo example](https://github.com/HCEMM/acceleration-toolbox/blob/main/.github/workflows/website.yml);
3. Go to `https://github.com/<username>/<repo>/settings/pages`;
4. Under "Source", select the branch you want to use (e.g., "main");
5. Click "Save" and wait for the page to be published. You will receive a URL where your page is available (e.g., `https://<your-github-username>.github.io/`).

Check [the actions section](https://github.com/HCEMM/acceleration-toolbox/actions) of your repo to see live the construction of the website.

## 3. GitHub in collaboration

Projects with multiple contributors require a more complex approach. In this section, multiple groups will be working on different parts of a pipeline, and we will be using GitHub to collaborate and manage our work. Right now, the pipeline is not working:

| Group | Task | Difficulty | Status |
|---------|---------|---------|---------|
| 1 | Reads Quality Check | Easy | ![Group1](https://github.com/HCEMM/acceleration-toolbox/actions/workflows/group1-ci.yml/badge.svg) |
| 2 | Reads Summary | Hard | ![Group2](https://github.com/HCEMM/acceleration-toolbox/actions/workflows/group2-ci.yml/badge.svg) |
| 3 | Annotation | Medium | ![Group3](https://github.com/HCEMM/acceleration-toolbox/actions/workflows/group3-ci.yml/badge.svg) |
| 4 | Gene Quantification | Easy | ![Group4](https://github.com/HCEMM/acceleration-toolbox/actions/workflows/group4-ci.yml/badge.svg) |
| 5 | Final Report | Medium | ![Group5](https://github.com/HCEMM/acceleration-toolbox/actions/workflows/group5-ci.yml/badge.svg) |
| All Groups | Complete Pipeline | - | ![Main](https://github.com/HCEMM/acceleration-toolbox/actions/workflows/full-pipeline.yml/badge.svg) |

### 3.1. Your task

As explained in [1.](#1-the-version-control-system), we will be using the "fork and pull" workflow to fix/complete this pipeline. This exercise will involve the following steps:

1. [Create a fork of this repository](https://github.com/HCEMM/acceleration-toolbox/fork), **while deselecting the option "Copy the main branch only"**. You now have your own copy of the repository where you can make changes without affecting the original repository. But this repository is currently only on GitHub!
<br/>
Before doing any new changes, go to the "Actions" tab of your forked repository, and click on "I understand my workflows, go ahead and enable them". This will be important later on, when you make changes and want to check if the tests pass.

2. Clone your forked repository by running the below command. This will create a local copy of your forked repository on your computer.
```
git clone https://github.com/<your-github-username>/acceleration-toolbox
```

3. Having a local copy on your system makes it easy to work on a project, especially by using [IDEs](https://github.com/HCEMM/sc-tutorials/blob/main/github_tutorial/README.md#21-in-an-ide). Use your preferred IDE to open the local repository, and the SC team will assist in discovering where version control is managed.

4. Chose your group from the table above, and checkout the corresponding branch (e.g., `git checkout group3` for Group 3). This will allow you to work on the specific part of the pipeline assigned to your group.

5. Make the necessary changes to complete your task. This may involve editing scripts, adding new files, or modifying existing ones.

6. Once you have made your changes, add, commit, and push them with a descriptive message (e.g., "Add command for Group 3"). This will save your changes in the remote repository, and will trigger the tests.

7. If the tests pass, you can create a pull request, by going to `https://github.com/iquasere/acceleration-toolbox/tree/group3` (e.g.) and clicking on "Compare & pull request". This will notify the maintainers of the original repository about your changes, and they can review and merge them if they are satisfactory. 
<br/>
If the tests do not pass, you will need to check the error messages, fix the issues, and repeat steps 5-7 until the tests pass.

8. Check the badge again to see if the tests are passing, and if so, your code will be merged into the main repository, and your contribution will become part of the main pipeline!

### 3.2. Testing is essential in collaborative or long-term projects

Testing code (also known as [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration)) is crucial for maintaining code quality. This pipeline is being tested using GitHub Actions, which allows us to automatically run tests every time a change is made to the code. This allows us to assess how changes affect the overall pipeline, and to ensure that the code is working as expected.

[GitHub Actions](https://github.com/features/actions) allows for automated workflows from your repository on GitHub, such as automated testing of your tools, or automated deployment into, e.g., package managers like Bioconda or PyPI. You actually ran GH actions already, when you set up your GitHub Pages.

------------------
|Previous|Home|Next|
|--------|----|----|
|[Home](../README.md)|[Home](../README.md)|[Containers](../02_Containers/README.md)
