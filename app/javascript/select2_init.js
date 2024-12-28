import $ from 'jquery';
import 'select2';

document.addEventListener('turbo:load', () => {
  $('.select2').select2({
    placeholder: "Select or Search an Option",
    allowClear: true,
    width: '100%'
  });
});
