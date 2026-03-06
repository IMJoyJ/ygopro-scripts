--フォーメーション・ユニオン
-- 效果：
-- 从下面效果选择1个发动：
-- ●选择自己场上表侧表示存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。
-- ●把自己场上存在的1只当作装备卡使用的同盟怪兽的装备解除，在自己场上表侧攻击表示特殊召唤。
function c26931058.initial_effect(c)
	-- 效果原文内容：从下面效果选择1个发动：●选择自己场上表侧表示存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。●把自己场上存在的1只当作装备卡使用的同盟怪兽的装备解除，在自己场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26931058.eftg)
	e1:SetOperation(c26931058.efop)
	c:RegisterEffect(e1)
end
c26931058.has_text_type=TYPE_UNION
-- 效果作用：检查场上是否存在满足条件的同盟怪兽（表侧表示且能装备其他怪兽）
function c26931058.filter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_UNION)
		-- 效果作用：检查是否存在可以被该同盟怪兽装备的怪兽
		and Duel.IsExistingMatchingCard(c26931058.filter2,tp,LOCATION_MZONE,0,1,c,c)
end
-- 效果原文内容：●选择自己场上表侧表示存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。
function c26931058.filter2(c,ec)
	-- 效果作用：检查目标怪兽是否可以作为同盟装备卡使用
	return c:IsFaceup() and ec:CheckUnionTarget(c) and aux.CheckUnionEquip(ec,c)
end
-- 效果原文内容：●把自己场上存在的1只当作装备卡使用的同盟怪兽的装备解除，在自己场上表侧攻击表示特殊召唤。
function c26931058.filter3(c,e,tp)
	return c:IsFaceup() and c:IsHasEffect(EFFECT_UNION_STATUS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果作用：判断是否为选择同盟装备效果（标签为0）或装备解除效果（标签为1）
function c26931058.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c26931058.filter1(chkc,tp)
		else return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and c26931058.filter3(chkc,e,tp) end
	end
	-- 效果作用：判断是否存在满足条件的同盟怪兽用于装备
	local b1=Duel.IsExistingTarget(c26931058.filter1,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	-- 效果作用：判断是否存在满足条件的同盟怪兽用于装备解除并特殊召唤
	local b2=Duel.IsExistingTarget(c26931058.filter3,tp,LOCATION_SZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 效果作用：让玩家选择同盟装备或装备解除效果
		op=Duel.SelectOption(tp,aux.Stringid(26931058,0),aux.Stringid(26931058,1))  --"同盟装备/装备解除"
	elseif b1 then
		-- 效果作用：让玩家选择同盟装备效果
		op=Duel.SelectOption(tp,aux.Stringid(26931058,0))  --"同盟装备"
	-- 效果作用：让玩家选择装备解除效果
	else op=Duel.SelectOption(tp,aux.Stringid(26931058,1))+1 end  --"装备解除"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(0)
		-- 效果作用：提示玩家选择一只同盟怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26931058,2))  --"请选择一只同盟怪兽"
		-- 效果作用：选择一只满足条件的同盟怪兽作为目标
		Duel.SelectTarget(tp,c26931058.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 效果作用：选择一只满足条件的同盟怪兽作为目标
		local g=Duel.SelectTarget(tp,c26931058.filter3,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		-- 效果作用：设置操作信息，表示将特殊召唤目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果原文内容：从下面效果选择1个发动：●选择自己场上表侧表示存在的1只同盟怪兽，给自己场上表侧表示存在的可以装备的怪兽装备。●把自己场上存在的1只当作装备卡使用的同盟怪兽的装备解除，在自己场上表侧攻击表示特殊召唤。
function c26931058.efop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 效果作用：获取当前连锁的目标怪兽
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		-- 效果作用：提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 效果作用：选择一只可以被目标怪兽装备的怪兽
		local g=Duel.SelectMatchingCard(tp,c26931058.filter2,tp,LOCATION_MZONE,0,1,1,tc,tc)
		local ec=g:GetFirst()
		-- 效果作用：将目标怪兽装备给选中的怪兽
		if ec and Duel.Equip(tp,tc,ec,false) then
			-- 效果作用：为装备的怪兽添加同盟怪兽属性
			aux.SetUnionState(tc)
		end
	else
		-- 效果作用：获取当前连锁的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 效果作用：将目标怪兽以表侧攻击表示特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end
