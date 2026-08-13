--砂利ケーン
-- 效果：
-- 选择自己以及对方场上存在的魔法·陷阱卡各1张发动。选择的卡回到持有者手卡。
function c48135190.initial_effect(c)
	-- 选择自己以及对方场上存在的魔法·陷阱卡各1张发动。选择的卡回到持有者手卡。
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
-- 筛选条件：卡为魔法·陷阱卡且能够被效果加入手卡。
function c48135190.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 目标选择时的发动条件判定：若chkc则不可作为连锁对象；若chk==0则检查双方场上是否各有至少1张符合条件的魔法·陷阱卡可供选择。
function c48135190.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1张可供选择且能加入手卡的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c48135190.filter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己场上是否存在至少1张可供选择且能加入手卡的魔法·陷阱卡，且不能选择发动者自身。
		and Duel.IsExistingTarget(c48135190.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 向发动玩家显示选择提示：‘请选择要返回手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动玩家从自己场上选择1张符合条件的魔法·陷阱卡作为效果对象（排除发动者自身），并登记为连锁对象。
	local g1=Duel.SelectTarget(tp,c48135190.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 再次向发动玩家显示选择提示：‘请选择要返回手牌的卡’（用于选择对方场上的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动玩家从对方场上选择1张符合条件的魔法·陷阱卡作为效果对象，并登记为连锁对象。
	local g2=Duel.SelectTarget(tp,c48135190.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：预测本次效果会将2张对象卡返回持有者手牌，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理：取出连锁对象，过滤出仍与效果关联的卡，将其全部返回持有者手牌。
function c48135190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的对象卡组（自己与对方场上被选择的魔法·陷阱卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍与效果关联的对象卡返回持有者手牌，送还原因为效果处理。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
