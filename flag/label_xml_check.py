import os
import re

# 定义两个输入参数，xml文件夹路径和图片文件夹路径
xml_path = "E:\腾讯\央视\自动学习包\旗帜训练\VOCdevkit\VOC2012\Annotations"
img_path = "E:\腾讯\央视\自动学习包\旗帜训练\VOCdevkit\VOC2012"

# 遍历xml文件夹中的所有xml文件
for xml_file in os.listdir(xml_path):
    # 打开xml文件，读取内容
    with open(os.path.join(xml_path, xml_file), "r") as f:
        content = f.read()
        # 用正则表达式提取folder和filename字段
        folder = re.search("<folder>(.*?)</folder>", content).group(1)
        filename = re.search("<filename>(.*?)</filename>", content).group(1)
        # 拼接成一个相对路径
        rel_path = os.path.join(folder, filename)
        # 检查图片文件夹中是否存在这个相对路径
        if not os.path.exists(os.path.join(img_path, rel_path)):
            # 如果不存在，就打印出xml文件的名字

            print(xml_file)
            # # If it doesn't exist, update the XML with the correct path
            # correct_rel_path = rel_path.replace("VOC2010", "VOC2012").replace("VOC2011", "VOC2012")
            # updated_content = re.sub(r"<folder>.*?</folder>", f"<folder>{os.path.dirname(correct_rel_path)}</folder>",
            #                          content, flags=re.DOTALL)
            # updated_content = re.sub(r"<filename>.*?</filename>",
            #                          f"<filename>{os.path.basename(correct_rel_path)}</filename>", updated_content,
            #                          flags=re.DOTALL)
            # # Write the updated content back to the XML file
            # with open(os.path.join(xml_path, xml_file), "w") as f:
            #     f.write(updated_content)
