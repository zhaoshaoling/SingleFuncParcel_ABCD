import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd


def create_cmp():
    from matplotlib import cm
    from matplotlib.colors import ListedColormap
    gray = cm.get_cmap('Blues_r', 256)
    newcolors = gray(np.linspace(0.5, 0.85, 256))
    newcmp = ListedColormap(newcolors)
    return newcmp


def density_show(input_file, x_label, y_label, out_path):
    cmap = create_cmp()
    data = pd.read_csv(input_file)
    x, y = 'gradient', 'variability'
    fig, ax = plt.subplots(figsize=(10, 12))
    sns.kdeplot(data=data, x=x, y=y, fill=True, levels=12, thresh=0.1, cmap=cmap, ax=ax)
    sns.regplot(data=data, x=x, y=y, scatter=False, color='steelblue', line_kws={'linewidth': '8'})
    ax.spines.right.set_visible(False)
    ax.spines.top.set_visible(False)
    #x_left, x_right = 0, 60000 # total=59412
    x_left, x_right = 200, 60000 
    y_low, y_high = 0.004, 0.054
    ratio = 0.8
    fontsize = 20

    # interval = 0.05
    ax.set_xlim([x_left, x_right])
    ax.set_ylim([y_low, y_high])
    ax.set_aspect(abs((x_right - x_left) / (y_low - y_high)) * ratio)
    ax.set_xlabel(x_label, fontsize=fontsize, fontname='Arial')
    ax.set_ylabel(y_label, fontsize=fontsize, fontname='Arial')
    ax.set_xlim(200,60000)
    ax.set_ylim(0.004,0.054)
    ax.set_xticks([200, 10000, 20000, 30000, 40000, 50000, 60000], fontsize=fontsize, fontname='Arial')
    ax.set_yticks(np.arange(0.01, 0.051, 0.01), fontsize=fontsize, fontname='Arial')

    fig.subplots_adjust(
        top=0.99,
        bottom=0.12,
        left=0.3,
        right=0.9,
        hspace=0.2,
        wspace=0.2
    )
    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize(fontsize)
        tick.label.set_fontname('Arial')
    for tick in ax.yaxis.get_major_ticks():
        tick.label.set_fontsize(fontsize)
        tick.label.set_fontname('Arial')
    for _, s in ax.spines.items():
        s.set_color('black')
        s.set_linewidth(3)
    #plt.show()
    plt.savefig(out_path, dpi=300)


if __name__ == '__main__':
    file_path = '/Users/zhaoshaoling/Documents/ABCD_indivTopography/step02_SESprediction/gradient'
    x_label = 'S-A Axis Rank'
    y_label = 'Inter-individual Variability'

    input_file = file_path + '/acrossSubjectsVariability_SAgradient_n3198.csv'
    out_path = file_path + '/Fig2E_individualVariability_withSAgradient.pdf'
    density_show(input_file, x_label, y_label, out_path)
   
  
