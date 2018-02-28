#!/bin/bash

meta_date=$(date +%F\ %T\ %:z)
file_date=$(date +%F)

echo Enter post title:
read meta_title
echo Enter author:
read meta_author
file_title=${meta_title//[^a-zA-Z0-9]/_}
file_title=${file_title,,}

outfile=_posts/${file_date}-$file_title.markdown
echo Generating: ${outfile}
cat >$outfile <<EOL
---
layout: post
title:  "${meta_title}"
date:   ${meta_date}
author: ${meta_author}
categories: hopsan news
---

write your news text here, replace this text
EOL
echo Now add content to $outfile using your favourite text editor, then push it to GitHub
