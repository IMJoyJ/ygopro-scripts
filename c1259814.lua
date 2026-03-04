--千六百七十七万工房
-- 效果：
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族变成机械族，那个属性也当作「光」「暗」「地」「水」「炎」「风」使用。
function c1259814.initial_effect(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 那只怪兽的种族变成机械族，那个属性也当作「光」「暗」「地」「水」「炎」「风」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1259814,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetTarget(c1259814.tg)
	e1:SetOperation(c1259814.op)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否满足效果发动条件（是否为表侧表示且不是机械族或属性不足6种）
function c1259814.filter(c)
	if not c:IsFaceup() then return false end
	if not c:IsRace(RACE_MACHINE) then return true end
	local ct=0
	local attr=1
	for i=1,7 do
		if c:IsAttribute(attr) then ct=ct+1 end
		attr=attr<<1
	end
	return ct<6
end
-- 处理效果发动时的选择目标阶段
function c1259814.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1259814.filter(chkc) end
	-- 检查场上是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c1259814.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c1259814.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动效果
function c1259814.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为对象怪兽增加地水火风光暗六种属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND+ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 将对象怪兽的种族变为机械族
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_MACHINE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
