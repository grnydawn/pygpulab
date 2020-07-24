"""main entry for pygpulab command-line interface"""

def main():
    from pygpulab import GPULab
    ret, _ = GPULab().run_command()
    return ret

if __name__ == "__main__":
    main()
