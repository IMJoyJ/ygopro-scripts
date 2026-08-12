--実力伯仲
-- 效果：
-- 选择自己以及对方场上表侧攻击表示存在的效果怪兽各1只才能发动。选择的2只怪兽的效果无效。那之后，只要选择的2只怪兽在场上表侧攻击表示存在，选择的怪兽不会被战斗破坏，不受这张卡以外的卡的效果影响，也不能作攻击和表示形式的变更。
function c65384188.initial_effect(c)
	-- 选择自己以及对方场上表侧攻击表示存在的效果怪兽各1只才能发动。选择的2只怪兽的效果无效。那之后，只要选择的2只怪兽在场上表侧攻击表示存在，选择的怪兽不会被战斗破坏，不受这张卡以外的卡的效果影响，也不能作攻击和表示形式的变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c65384188.target)
	e1:SetOperation(c65384188.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数，用于寻找场上表侧攻击表示且未被无效的效果怪兽
function c65384188.filter(c)
	-- 判断卡片是否处于表侧攻击表示，且为未被无效的效果怪兽
	return c:IsPosition(POS_FACEUP_ATTACK) and aux.NegateEffectMonsterFilter(c)
end
-- 定义效果发动的目标选择函数，进行对象合法性检测
function c65384188.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时，检查自己场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c65384188.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 在发动时，检查对方场上是否存在至少1只符合条件的怪兽
		and Duel.IsExistingTarget(c65384188.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧攻击表示的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c65384188.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置选择卡片时的提示信息为“请选择表侧攻击表示的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择对方场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c65384188.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理函数，使选择的2只怪兽效果无效，并在满足条件时适用后续的持续效果
function c65384188.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的2只目标怪兽
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		local a=0
		-- 选择的2只怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- 选择的2只怪兽的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		if tc1:IsCanBeDisabledByEffect(e) then
			tc1:RegisterEffect(e1)
			tc1:RegisterEffect(e2)
			a=a+1
		end
		if tc2:IsCanBeDisabledByEffect(e) then
			local e3=e1:Clone()
			local e4=e2:Clone()
			tc2:RegisterEffect(e3)
			tc2:RegisterEffect(e4)
			a=a+1
		end
		if tc1:IsDefensePos() or tc2:IsDefensePos() or a~=2 then return end
		-- 中断当前效果，使后续处理与无效化处理不视为同时进行
		Duel.BreakEffect()
		c65384188.reg(c,tc1,tc2)
		c65384188.reg(c,tc2,tc1)
	end
end
-- 定义辅助函数，为目标怪兽注册后续的持续效果
function c65384188.reg(c,tc1,tc2)
	tc1:RegisterFlagEffect(65384188,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 只要选择的2只怪兽在场上表侧攻击表示存在
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c65384188.posop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e1)
	-- 选择的怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c65384188.effcon)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetLabelObject(tc2)
	tc1:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	tc1:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	tc1:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(c65384188.efilter)
	tc1:RegisterEffect(e5)
end
-- 定义表示形式变更时的处理，若怪兽不再处于表侧攻击表示，则重置其标记
function c65384188.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(65384188)~=0 and not c:IsPosition(POS_FACEUP_ATTACK) then
		c:ResetFlagEffect(65384188)
	end
end
-- 定义持续效果的适用条件，要求两只怪兽都必须带有对应的标记（即都必须在场上表侧攻击表示存在）
function c65384188.effcon(e)
	return e:GetHandler():GetFlagEffect(65384188)~=0 and e:GetLabelObject():GetFlagEffect(65384188)~=0
end
-- 定义效果免疫过滤器，使怪兽不受这张卡以外的卡的效果影响
function c65384188.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
