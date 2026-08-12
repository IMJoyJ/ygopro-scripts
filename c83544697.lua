--ガスタの交信
-- 效果：
-- 选择自己墓地存在的2只名字带有「薰风」的怪兽，加入卡组洗切。那之后，选择对方场上存在的1张卡破坏。
function c83544697.initial_effect(c)
	-- 选择自己墓地存在的2只名字带有「薰风」的怪兽，加入卡组洗切。那之后，选择对方场上存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83544697.target)
	e1:SetOperation(c83544697.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的名字带有「薰风」的怪兽且能回到卡组
function c83544697.filter1(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果发动时的对象选择与合法性检查
function c83544697.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在至少2只可以回到卡组的「薰风」怪兽
	if chk==0 then return Duel.IsExistingTarget(c83544697.filter1,tp,LOCATION_GRAVE,0,2,nil)
		-- 检查对方场上是否存在至少1张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2只名字带有「薰风」的怪兽作为对象
	local g1=Duel.SelectTarget(tp,c83544697.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	-- 设置操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 过滤条件：在场上且由指定玩家控制的卡
function c83544697.filter2(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 效果处理的核心逻辑
function c83544697.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的对象卡片组
	local g=Duel.GetTargetsRelateToChain()
	local g1=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local g2=g:Filter(c83544697.filter2,nil,1-tp)
	-- 如果墓地的2只目标怪兽依然存在，则将它们送回卡组并洗牌，并确认是否成功送回2张
	if g1:GetCount()==2 and Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==2 then
		-- 计算实际被送回主卡组或额外卡组的卡片数量
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct==2 and g2:GetCount()>0 then
			-- 中断当前效果处理，用于实现“那之后”的非同时处理时点
			Duel.BreakEffect()
			-- 破坏选择的对方场上的卡
			Duel.Destroy(g2,REASON_EFFECT)
		end
	end
end
