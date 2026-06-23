--魔力誘爆
-- 效果：
-- 对方的魔法与陷阱卡区域表侧表示存在的魔法卡被送去墓地的场合才能发动。选择场上表侧表示存在的1只怪兽破坏。
function c22869904.initial_effect(c)
	-- 创建效果，设置为发动时破坏怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c22869904.condition)
	e1:SetTarget(c22869904.target)
	e1:SetOperation(c22869904.activate)
	c:RegisterEffect(e1)
end
-- 判断被送去墓地的卡是否为对方魔法区表侧表示的魔法卡
function c22869904.cfilter(c,tp)
	return c:IsType(TYPE_SPELL) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(1-tp) and c:GetPreviousSequence()~=5
end
-- 判断是否有满足条件的卡送去墓地
function c22869904.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22869904.cfilter,1,nil,tp)
end
-- 筛选场上表侧表示的怪兽
function c22869904.filter(c)
	return c:IsFaceup()
end
-- 选择场上表侧表示存在的1只怪兽作为破坏对象
function c22869904.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c22869904.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c22869904.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧表示存在的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c22869904.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果，破坏选定的怪兽
function c22869904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
