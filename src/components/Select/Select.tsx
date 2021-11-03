import { useRef } from 'react';
import { useState } from 'react';
import { FaChevronDown, FaChevronUp } from 'react-icons/fa';
import {
  SelectMain,
  ContainerSelected,
  SelectContainer,
  ListOptions,
  Option,
} from './Select.styles';

export interface OptionDefault {
  [x: string]: string | number | undefined;
  name?: string;
}
interface SelectProps {
  options: OptionDefault[];
  labelValue?: string;
  keyValue?: string;
  setOptionSelected: React.Dispatch<React.SetStateAction<OptionDefault>>;
  option: OptionDefault;
}

export const Select = ({
  options,
  labelValue = 'name',
  keyValue = 'id',
  setOptionSelected,
  option,
}: SelectProps) => {
  const [open, setOpen] = useState(false);
  const node = useRef(null);

  const setOption = (option: OptionDefault) => {
    setOptionSelected(option);
    setOpen(false);
  };

  const showChevron = () => {
    if (options.length > 0) {
      return open ? (
        <FaChevronUp />
      ) : (
        <FaChevronDown data-testid="select-chevron" />
      );
    }
    return null;
  };

  return (
    <SelectContainer ref={node}>
      <SelectMain data-testid="select-main" onClick={() => setOpen(!open)}>
        <ContainerSelected>
          {options.length ? (
            <span>{option[labelValue] ? option[labelValue] : 'Selecione'}</span>
          ) : (
            <span>Nenhuma opção encontrada</span>
          )}
          {showChevron()}
        </ContainerSelected>
      </SelectMain>
      {open && (
        <ListOptions>
          {options.map((option: OptionDefault) => (
            <Option key={option[keyValue]} onClick={() => setOption(option)}>
              {option[labelValue]}
            </Option>
          ))}
        </ListOptions>
      )}
    </SelectContainer>
  );
};

export default Select;
