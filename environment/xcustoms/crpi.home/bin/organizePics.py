import logging
import platform
from pathlib import Path
from PIL import Image
from PIL.ExifTags import TAGS
from datetime import datetime
import hashlib
import shutil

_logger = logging.getLogger(__name__)
_logger.setLevel('INFO')
_logger.addHandler(logging.StreamHandler())


_target_tags = ['DateTime', 'DateTimeOriginal', 'DateTimeDigitized']


def process_jpeg_file(file_, base_dir) -> (Path, Path, str):
    _logger.debug(f'Got file {file_}')
    if file_.suffix.lower() not in ['.jpg', '.jpeg']:
        _logger.debug(f'Ignoring file {file_} with suffix {file_.suffix.lower()}')
        return

    _logger.info(f'Processing file {file_}')
    with Image.open(file_) as fr:
        exif_data = fr._getexif()
        exif_data = {TAGS[k]: v
        for k, v in exif_data.items()
        if TAGS.get(k, '') in _target_tags
        }

        _logger.debug(f'\texif_data: {exif_data}')
        time_stamp = None
        for t in _target_tags:
            time_stamp = exif_data.get(t, None)
            if time_stamp is not None:
                _logger.debug(f'\tFound tag: {t} = {time_stamp}')
                break

        if time_stamp is None:
            _logger.error(f'lTimeStamp information not found for file: {file_}. Skipping.')
            return

        time_stamp = datetime.strptime(time_stamp, '%Y:%m:%d %H:%M:%S')

        # date_stamp = time_stamp.split(' ')[0]
        target_dir = base_dir / time_stamp.strftime('%Y/%m')
        if not target_dir.is_dir():
            _logger.info(f'Creating target directory: {target_dir}')
            target_dir.mkdir(parents=True)

        with file_.open('rb') as fr:
            checksum = hashlib.md5(fr.read()).hexdigest()

        target_file = target_dir / ('IMG_' + time_stamp.strftime('%Y%m%d-%H%M%S') + '.JPG')

        return file_, target_file, checksum


def processDir(dir_, base_dir):
    _logger.debug(f'Processing directory {dir_}')
    files_info = []
    for file in dir_.glob('*'):
        if file.is_dir():
            files_info = files_info + processDir(file, base_dir)
        else:
            files_info.append(process_jpeg_file(file, base_dir))

    return files_info


def _read_checksums(checksums_file: Path):
    checksums = {}
    _logger.info(f'Reading checksums from {checksums_file}')
    with checksums_file.open('r') as fr:
        for line in fr:
            cs, file_name = line.split(' ')
            file_name = file_name.replace('\n', '')
            if cs in checksums:
                _logger.warning(f'Found duplicate checksum: {cs} for {checksums[cs]} and {file_name}')
            checksums[cs] = file_name
    return checksums


def move_files(files_info, checksums):
    failed_attempts_counter = 0
    for info in files_info:
        if info is None:
            continue
        source, dest, cs = info
        existing = checksums.get(cs, None)
        if existing is not None:
            _logger.info(f'Checksum found: {cs} -> {existing}. Skipping file {source}.')
        else:
            try:
                _logger.info(f'Moving file {source} to {dest}')
                shutil.move(source, dest)
                checksums[cs] = dest
                failed_attempts_counter = 0
            except:
                _logger.error(f'Failed to copy file {source} to {dest}')
                failed_attempts_counter += 1
                if failed_attempts_counter > 10:
                    _logger.info(f'Too many consecutive failed attempts to copy files. Giving up.')
                    return False
    return True


def main():
    _logger.debug(f'OS name is {platform.system()}')
    target_dir = Path('/Volumes/backup' if platform.system() == 'Darwin' else '/mnt/dsbackup')
    _logger.debug(f'Checking for target dir: {target_dir}')
    if not target_dir.is_dir():
        raise EnvironmentError(f'The NAS doesn\'t seem to be mounted. Will not proceed.')

    base_dir = target_dir / 'photos'
    checksums_file = base_dir / 'checksums'
    _logger.debug('Loading checksums from NAS: {checksums_file}')
    checksums = _read_checksums(checksums_file)
    _logger.info(f'Read {len(checksums)} checksums')

    files_info = []
    for file in Path('.').glob('*'):
        if file.is_dir():
            files_info = files_info + processDir(file, base_dir)
        else:
            files_info.append(process_jpeg_file(file, base_dir))

    if not files_info:
        _logger.info(f'No files found to process. Exiting')
        return

    target_checksum_file = checksums_file
    if not move_files(files_info, checksums):
        target_checksum_file = Path('checksums')

    _logger.info(f'Writing {len(checksums)} checksums to: {target_checksum_file}')
    with target_checksum_file.open('w') as fw:
        for k, v in checksums.items():
            fw.write(f'{k} {v}\n')



if __name__ == '__main__':
    main()
