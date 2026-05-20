--はさみ撃ち
-- 效果：
-- 选择自己场上存在的2只怪兽和对方场上存在的1只怪兽破坏。
function c83887306.initial_effect(c)
	-- 选择自己场上存在的2只怪兽和对方场上存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83887306.target)
	e1:SetOperation(c83887306.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的对象选择与合法性检测
function c83887306.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少2只可以成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,2,nil)
		-- 以及对方场上是否存在至少1只可以成为效果对象的怪兽
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上2只怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,2,2,nil)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，包含破坏分类和3张目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,3,0,0)
end
-- 效果处理：若3张目标卡片均合法存在，则将其全部破坏
function c83887306.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==3 then
		-- 因效果将这些卡片破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
