--尾も白い黒猫
-- 效果：
-- 反转：将对方场上2只怪兽与自己场上1只怪兽弹回持有者手卡。
function c8634636.initial_effect(c)
	-- 反转：将对方场上2只怪兽与自己场上1只怪兽弹回持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8634636,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c8634636.target)
	e1:SetOperation(c8634636.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的对象选择与处理信息设置：选择对方场上2只怪兽和自己场上1只怪兽作为对象。
function c8634636.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 检查自己场上是否存在至少1只可以返回手牌的怪兽
	if Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少2只可以返回手牌的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,2,nil) then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上2只可以返回手牌的怪兽作为效果对象
		local g1=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,2,2,nil)
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择自己场上1只可以返回手牌的怪兽作为效果对象
		local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,nil)
		g1:Merge(g2)
		-- 设置连锁处理信息，表示操作分类为返回手牌，操作对象为选择的卡片组
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,g1:GetCount(),0,0)
	end
end
-- 效果处理：将仍存在于场上的对象怪兽返回持有者手卡
function c8634636.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local sg=g:Filter(Card.IsRelateToEffect,nil,e)
		-- 将符合条件的对象怪兽因效果返回持有者的手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
