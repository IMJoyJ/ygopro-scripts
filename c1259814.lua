--千六百七十七万工房
-- 效果：
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族变成机械族，那个属性也当作「光」「暗」「地」「水」「炎」「风」使用。
function c1259814.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族变成机械族，那个属性也当作「光」「暗」「地」「水」「炎」「风」使用。
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
-- 筛选可作为对象的场上表侧表示怪兽：若该怪兽不是机械族则直接通过；若已是机械族，则检查其当前属性种类数量，只有未同时拥有光暗地水炎风全属性（即属性种类少于6种）时才能选择。
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
-- 效果发动时的取对象处理：若指定对象则校验其位于怪兽区且满足筛选函数；若为发动确认阶段则检查场上是否存在至少1只满足条件的表侧表示怪兽，存在才可发动；随后给出选择提示并让玩家选择1只符合条件的表侧表示怪兽作为对象。
function c1259814.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1259814.filter(chkc) end
	-- 发动合法性检查：确认场上存在至少1只符合筛选条件的表侧表示怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c1259814.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向选牌玩家显示选择提示信息“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从双方怪兽区域选择1只满足筛选条件的表侧表示怪兽，并设定为这张卡效果的对象。
	Duel.SelectTarget(tp,c1259814.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理阶段：先取得效果持有者（这张卡本身）及对象怪兽；若对象仍与此效果关联且表侧表示，则分别赋予其“属性追加光暗地水炎风”和“种族变成机械族”的效果，并规定这些效果在标准离场/移动/重置等情况下失效。
function c1259814.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时所选择的那个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那个属性也当作「光」「暗」「地」「水」「炎」「风」使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND+ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的种族变成机械族。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_MACHINE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
