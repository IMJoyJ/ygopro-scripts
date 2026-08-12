--砂利ケーン
-- 效果：
-- 选择自己以及对方场上存在的魔法·陷阱卡各1张发动。选择的卡回到持有者手卡。
function c48135190.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，取对象，自由时点，提示在结束阶段时点
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c48135190.target)
	e1:SetOperation(c48135190.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选魔法·陷阱卡且可以送入手牌的卡片
function c48135190.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果的发动条件判断，检查自己和对方场上是否存在魔法·陷阱卡
function c48135190.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c48135190.filter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方场上是否存在魔法·陷阱卡
		and Duel.IsExistingTarget(c48135190.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上的魔法·陷阱卡作为目标
	local g1=Duel.SelectTarget(tp,c48135190.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的魔法·陷阱卡作为目标
	local g2=Duel.SelectTarget(tp,c48135190.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，将选择的两张卡设为处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果发动时执行的操作，将符合条件的卡送入手牌
function c48135190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的卡以效果原因送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
