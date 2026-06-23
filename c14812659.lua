--覚星師ライズベルト
-- 效果：
-- 1回合1次，选择场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级上升1星。这个效果在对方回合也能发动。
function c14812659.initial_effect(c)
	-- 1回合1次，选择场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级上升1星。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14812659,0))  --"等级上升1"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c14812659.target)
	e1:SetOperation(c14812659.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽（表侧表示且等级大于等于1）
function c14812659.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 设置效果的目标选择函数
function c14812659.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14812659.filter(chkc) end
	-- 判断是否满足发动条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c14812659.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择一个符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c14812659.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 设置效果的处理函数
function c14812659.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽的等级上升1星
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
