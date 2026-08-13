--フォーメーション・ユニオン
-- 效果：
-- 从下面效果选择1个发动：
-- ●选择自己场上表侧表示存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。
-- ●把自己场上存在的1只当作装备卡使用的同盟怪兽的装备解除，在自己场上表侧攻击表示特殊召唤。
function c26931058.initial_effect(c)
	-- 从下面效果选择1个发动：●选择自己场上表侧表示存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。●把自己场上存在的1只当作装备卡使用的同盟怪兽的装备解除，在自己场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26931058.eftg)
	e1:SetOperation(c26931058.efop)
	c:RegisterEffect(e1)
end
c26931058.has_text_type=TYPE_UNION
-- 定义过滤器1：用于选择可以作为同盟装备效果对象的同盟怪兽，要求该怪兽表侧表示且为同盟怪兽，并且场上存在另一只能够装备它的怪兽（满足filter2）。
function c26931058.filter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_UNION)
		-- 检查场上（主要怪兽区）是否存在至少1只除候选同盟怪兽c以外的、能够被c作为同盟装备装备的怪兽，确保c不是孤立无装备对象。
		and Duel.IsExistingMatchingCard(c26931058.filter2,tp,LOCATION_MZONE,0,1,c,c)
end
-- 定义过滤器2：用于选择可以成为同盟装备对象的怪兽，要求该怪兽表侧表示，并且同盟怪兽ec能够根据同盟规则合法装备到它身上（同时通过CheckUnionTarget与aux.CheckUnionEquip的判定）。
function c26931058.filter2(c,ec)
	-- 返回该怪兽表侧表示、ec可以将其作为同盟装备对象且同盟装备规则允许，三个条件同时满足。
	return c:IsFaceup() and ec:CheckUnionTarget(c) and aux.CheckUnionEquip(ec,c)
end
-- 定义过滤器3：用于选择当作装备卡使用的同盟怪兽（即处于同盟状态的同盟怪兽），要求其表侧表示、具有EFFECT_UNION_STATUS效果且可以被玩家tp以表侧攻击表示特殊召唤。
function c26931058.filter3(c,e,tp)
	return c:IsFaceup() and c:IsHasEffect(EFFECT_UNION_STATUS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动目标选择函数：若在连锁确认阶段检查已选对象chkc，则根据之前选择的选项（e:GetLabel）验证对象合法性：选项0要求对象是自己场上表侧表示的同盟怪兽且通过filter1；选项1要求对象是自己魔陷区表侧表示、具有同盟状态且可特殊召唤的同盟怪兽。
function c26931058.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c26931058.filter1(chkc,tp)
		else return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and c26931058.filter3(chkc,e,tp) end
	end
	-- 判断“同盟装备”选项是否可选：自己场上存在表侧表示且可装备的同盟怪兽，并且自己魔陷区有空位用于放置装备卡。
	local b1=Duel.IsExistingTarget(c26931058.filter1,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	-- 判断“装备解除”选项是否可选：自己魔陷区存在当作装备卡使用且可以特殊召唤的同盟怪兽，并且自己主要怪兽区有空位用于特殊召唤。
	local b2=Duel.IsExistingTarget(c26931058.filter3,tp,LOCATION_SZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个选项都可用时，向玩家弹出选择菜单，0代表“同盟装备”，1代表“装备解除”，并把选择结果存入label。
		op=Duel.SelectOption(tp,aux.Stringid(26931058,0),aux.Stringid(26931058,1))  --"同盟装备/装备解除"
	elseif b1 then
		-- 当只有“同盟装备”可用时，直接让玩家选择该选项，op为0。
		op=Duel.SelectOption(tp,aux.Stringid(26931058,0))  --"同盟装备"
	-- 当只有“装备解除”可用时，让玩家选择该选项，由于SelectOption从0开始，+1后得到op=1，与内部标记一致。
	else op=Duel.SelectOption(tp,aux.Stringid(26931058,1))+1 end  --"装备解除"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(0)
		-- 在“同盟装备”分支中，向玩家发送提示：请选择一只同盟怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26931058,2))  --"请选择一只同盟怪兽"
		-- 在“同盟装备”分支中，将选择自己场上表侧表示且满足filter1的1只同盟怪兽作为效果对象。
		Duel.SelectTarget(tp,c26931058.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 在“装备解除”分支中，向玩家发送提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 在“装备解除”分支中，选择自己魔陷区表侧表示、具有同盟状态且满足filter3的1只同盟怪兽作为效果对象。
		local g=Duel.SelectTarget(tp,c26931058.filter3,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		-- 为当前连锁设置操作信息：该效果将进行1只怪兽的特殊召唤，对象为g中的卡。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果结算函数：若之前选择的是“同盟装备”（label=0），则获取对象同盟怪兽，确认仍与效果关联且表侧后，选择可装备对象并执行装备，同时设置同盟状态；若选择的是“装备解除”（label≠0），则获取对象装备同盟怪兽，若仍关联则将其表侧攻击表示特殊召唤。
function c26931058.efop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁效果的对象卡（同盟装备分支中选择的同盟怪兽）。
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		-- 在结算装备时，向玩家发送提示：请选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择自己场上除了tc自身以外、能够装备tc（通过filter2）的1只怪兽作为装备对象。
		local g=Duel.SelectMatchingCard(tp,c26931058.filter2,tp,LOCATION_MZONE,0,1,1,tc,tc)
		local ec=g:GetFirst()
		-- 若成功选到装备对象ec，则将同盟怪兽tc作为装备卡装备到ec上（false表示保持原表示形式不强制表侧），装备成功则进入后续处理。
		if ec and Duel.Equip(tp,tc,ec,false) then
			-- 为tc附加同盟状态（EFFECT_UNION_STATUS），使其正式成为当作装备卡使用的同盟怪兽。
			aux.SetUnionState(tc)
		end
	else
		-- 获取当前连锁效果的对象卡（装备解除分支中选择的当作装备卡使用的同盟怪兽）。
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将该同盟怪兽以表侧攻击表示特殊召唤到其持有者的场上（tp玩家）。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end
