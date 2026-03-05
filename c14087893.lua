--月の書
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c14087893.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(c14087893.target)
	e1:SetOperation(c14087893.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否为表侧表示且可以变成里侧表示
function c14087893.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果处理时的选对象阶段，用于确认目标怪兽是否满足条件
function c14087893.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14087893.filter(chkc) end
	-- 检查是否满足发动条件，即场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c14087893.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c14087893.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表明将要改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果发动时的处理函数，用于执行效果内容
function c14087893.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果所选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
