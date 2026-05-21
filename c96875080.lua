--大気圏外射撃
-- 效果：
-- 把自己场上1只名字带有「外星」的怪兽送去墓地发动。场上的1张魔法或者陷阱卡破坏。
function c96875080.initial_effect(c)
	-- 把自己场上1只名字带有「外星」的怪兽送去墓地发动。场上的1张魔法或者陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c96875080.cost)
	e1:SetTarget(c96875080.target)
	e1:SetOperation(c96875080.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的名字带有「外星」且能作为代价送去墓地的怪兽
function c96875080.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc) and c:IsAbleToGraveAsCost()
end
-- 发动代价（Cost）处理：检查并选择自己场上1只名字带有「外星」的怪兽送去墓地
function c96875080.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否存在至少1只满足过滤条件的「外星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96875080.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只满足过滤条件的「外星」怪兽
	local g=Duel.SelectMatchingCard(tp,c96875080.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：魔法或陷阱卡
function c96875080.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的目标（Target）处理：选择场上1张魔法或陷阱卡作为对象，并设置破坏操作信息
function c96875080.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c96875080.filter(chkc) and chkc~=e:GetHandler() end
	-- 在发动阶段（chk==0）检查场上是否存在除这张卡以外的魔法或陷阱卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c96875080.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c96875080.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置当前连锁的操作信息为：破坏1张目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果运行（Operation）处理：破坏作为对象的卡
function c96875080.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
