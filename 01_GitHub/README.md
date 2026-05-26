# GitHub & Version Control

In this workshop, we will use GitHub to collaborate on building a bioinformatics pipeline. GitHub is a platform for version control, which allows multiple people to work on the same project, track changes, and manage contributions efficiently.

## 0. Before the Workshop

Please make sure you:

- [Register for a GitHub account](https://github.com/signup)
- [Familiarize yourself with the interface](https://docs.github.com/en/get-started/quickstart) (optional but helpful)
- [Explore the workshop repository](https://github.com/HCEMM/acceleration-toolbox)

## 1. The Version Control System

One of the Scientific Computing tutorials explains the main concepts of version control, go [take a look](https://github.com/HCEMM/sc-tutorials/blob/main/github_tutorial/README.md#2-the-version-control-workflow).

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

Check [the actions section](https://github.com/HCEMM/acceleration-toolbox/actions) of your repo to see live the construciton of the website.

## 3. GitHub in collaboration

Projects with multiple contributors require a more complex approach. In this section, multiple groups will be working on different parts of a pipeline, and we will be using GitHub to collaborate and manage our work. As explained in [1.](#1-the-version-control-system), we will be using the "fork and pull" workflow, which involves the following steps:

1. [Create a fork of this repository](https://github.com/HCEMM/acceleration-toolbox/fork): you now have your own copy of the repository where you can make changes without affecting the original repository. But this repository is currently only on GitHub!

2. Clone your forked repository by running the below command. This will create a local copy of your forked repository on your computer.
```
git clone https://github.com/<your-github-username>/acceleration-toolbox
```

3. Having a local copy on your system makes it easy to work on a project, especially by using [IDEs](https://github.com/HCEMM/sc-tutorials/blob/main/github_tutorial/README.md#21-in-an-ide). Use your preferred IDE to open the local repository, and the SC team will assist in discovering where version control is managed.

### 3.1. Testing is essential in collaborative or long-term projects

Testing code (also known as [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration)) is crucial for maintaining code quality. It can also be one of the most boring parts of programming.

[GitHub Actions](https://github.com/features/actions) allows for automated workflows from your repository on GitHub, such as automated testing of your tools, or automated deployment into, e.g., package managers like Bioconda or PyPI. You actually ran GH actions already, when you set up your GitHub Pages.

### 3.2. Your task

We have multiple groups for multiple different tasks. Each group will be working on a different part of the pipeline, and you will be collaborating with your group members to complete the task.

------------------
|Previous|Home|Next|
|--------|----|----|
|[Home](../README.md)|[Home](../README.md)|[Containers](../02_Containers/README.md)
