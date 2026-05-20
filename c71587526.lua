--因果切断
-- 效果：
-- ①：丢弃1张手卡，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽除外。这个效果除外的卡的同名卡在对方墓地存在的场合，再把那些同名卡全部除外。
function c71587526.initial_effect(c)
	-- ①：丢弃1张手卡，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽除外。这个效果除外的卡的同名卡在对方墓地存在的场合，再把那些同名卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c71587526.cost)
	e1:SetTarget(c71587526.target)
	e1:SetOperation(c71587526.activate)
	c:RegisterEffect(e1)
end
-- 代价处理函数：丢弃1张手卡
function c71587526.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：表侧表示且可以除外的卡
function c71587526.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果发动时的对象选择与操作信息注册
function c71587526.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c71587526.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c71587526.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c71587526.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：除外该对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 过滤条件：对方墓地中与被除外怪兽同名且可以除外的卡
function c71587526.rfilter(c,tc)
	return c:IsCode(tc:GetCode()) and c:IsAbleToRemove()
end
-- 效果处理的核心逻辑
function c71587526.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍表侧表示存在、与效果有关联，且成功除外
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取对方墓地中与被除外怪兽同名的所有卡片
		local rg=Duel.GetMatchingGroup(c71587526.rfilter,tp,0,LOCATION_GRAVE,nil,tc)
		if #rg>0 then
			-- 中断效果处理，使后续的除外处理不与前面的除外同时进行（防止错时点）
			Duel.BreakEffect()
			-- 将对方墓地中的同名卡全部除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
