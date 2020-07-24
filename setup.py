"pygpulab setup module."

def main():

    from setuptools import setup
    from pygpulab.main import GPULab as gpulab

    console_scripts = ["pygpulab=pygpulab.__main__:main"]
    install_requires = ["microapp"]

    setup(
        name=gpulab._name_,
        version=gpulab._version_,
        description=gpulab._description_,
        long_description=gpulab._long_description_,
        author=gpulab._author_,
        author_email=gpulab._author_email_,
        classifiers=[
            "Development Status :: 3 - Alpha",
            "Intended Audience :: Science/Research",
            "Topic :: Scientific/Engineering",
            "License :: OSI Approved :: MIT License",
            "Programming Language :: Python :: 3",
            "Programming Language :: Python :: 3.5",
            "Programming Language :: Python :: 3.6",
            "Programming Language :: Python :: 3.7",
            "Programming Language :: Python :: 3.8",
        ],
        keywords="pygpulab",
        packages=[ "pygpulab" ],
        include_package_data=True,
        install_requires=install_requires,
        entry_points={ "console_scripts": console_scripts,
            "microapp.projects": "pygpulab = pygpulab"},
        project_urls={
            "Bug Reports": "https://github.com/grnydawn/pygpulab/issues",
            "Source": "https://github.com/grnydawn/pygpulab",
        }
    )

if __name__ == '__main__':
    import multiprocessing
    multiprocessing.freeze_support()
    main()
