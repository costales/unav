import os, tarfile

dir_unav     = '.local/share/navigator.costales'
dir_download = '.local/share/ubuntu-download-manager/Downloads'

def rm_older():
    dir_src = os.path.join(os.path.expanduser('~'), dir_download)
    for filename in os.listdir(dir_src):
        if 'unav_' in filename and '.tar.gz' in filename:
            src = os.path.join(os.path.expanduser('~'), dir_download, filename)
            os.remove(src)

def mv_voice(tar):
    print('tar.gz: ' + tar)
    
    tar = tarfile.open(tar)
    tar.extractall(os.path.join(os.path.expanduser('~'), dir_unav))
    tar.close()
    
    rm_older()
