import os

all_num_topics = [6, 4, 4]

def get_folder_names(topic_paths):
    folder_names = list()
    for topic_path in topic_paths:
        if topic_path == [0]:
            folder_names.append('_' + str(all_num_topics[0]))
        else:
            folder_names.append('.' + '.'.join(str(x) for x in topic_path) + '_' + str(all_num_topics[len(topic_path)]))
    return folder_names


def get_topic_paths(level):
    if level == 0:
        return [[0]]
    else:
        previous_paths = []
        next_paths = []
        for current_level in range(level):
            if previous_paths == []:
                for i in range(all_num_topics[current_level]):
                    previous_paths.append([i + 1])
            else:
                for i in range(all_num_topics[current_level]):
                    for previous_path in previous_paths:
                        next_paths.append(previous_path + [i + 1])
                previous_paths = next_paths
            next_paths = []
        return previous_paths


def find_parent_folder_name(folder_name, folder_names):
    level = folder_name.count('.')
    if level == 0:
        return ""
    else:
        index = folder_name.rfind('.')
        if index == 0:
            return "_" + str(all_num_topics[0])
        else:
            return folder_name[:index] + '_' + str(all_num_topics[level - 1])


def recover_network(folder_name, folder_names):
    parent_folder_name = find_parent_folder_name(folder_name, folder_names)
    recovered_doc_term_file_path = "../data/" + folder_name + ".txt"
    if parent_folder_name == '':
        # create doc-term file for the root
        pt_file_path = "../data/PT.txt"
        term_file_path = "../data/term.txt"

        doc_term_dict = dict()
        term_index_dict = dict()

        with open(pt_file_path, 'rb') as pt_file:
            for line in pt_file:
                ids = line.split('\t')
                if ids[0] in doc_term_dict:
                    doc_term_dict[ids[0].strip()].append(ids[1].strip())
                else:
                    doc_term_dict[ids[0].strip()] = list()
                    doc_term_dict[ids[0].strip()].append(ids[1].strip())

        with open(term_file_path, 'rb') as term_file:
            for line in term_file:
                ids = line.split('\t')
                term_index_dict[ids[0].strip()] = ids[1].strip()

        with open(recovered_doc_term_file_path, 'wb') as recovered_file:
            for (doc_id, term_ids) in doc_term_dict.iteritems():
                # recovered_file.write(doc_id + " ")
                for term_id in term_ids:
                    recovered_file.write(term_index_dict[term_id] + " ")
                recovered_file.write("\n")
    else:
        #create doc-term file for the non-root nodes from the topic model results
        topic_state_file_path = "../data/" + parent_folder_name + "/topic-state"
        parent_doc_term_file_path = "../data/" + parent_folder_name + ".txt"

        term_topic_dict = dict()
        with open(topic_state_file_path, 'rb') as topic_state_file:
            next(topic_state_file)
            next(topic_state_file)
            next(topic_state_file)
            for line in topic_state_file:
                elements = line.split(' ')
                term_topic_dict[elements[-2].strip()] = elements[-1].strip()
        selected_topic = str(int(folder_name[folder_name.find('_') - 1]) - 1)

        with open(recovered_doc_term_file_path, 'wb') as recovered_doc_term_file:
            with open(parent_doc_term_file_path, 'rb') as parent_doc_term_file:
                import re
                for line in parent_doc_term_file:
                    elements = re.split(';| |,|-|\n', line)
                    newline = ""
                    for element in elements:
                        if element.strip() == "":
                            continue
                        if element.strip() not in term_topic_dict:
                            # print element.strip()
                            pass
                        elif term_topic_dict[element.strip()] == selected_topic:
                            newline += element + " "
                    if newline.strip() != "":
                        recovered_doc_term_file.write(newline.strip() + "\n")


folder_names = []
for level in range(len(all_num_topics)):
    topic_paths = get_topic_paths(level)
    folder_names += get_folder_names(topic_paths)

print folder_names
for folder_name in folder_names:
    print "Building doc-term file: " + folder_name
    recover_network(folder_name, folder_names)
    print "Running flat_kert for the built doc-term file"
    os.system("flat_kert.bat " + folder_name + ' ' + str(all_num_topics[folder_name.count('.')]))
