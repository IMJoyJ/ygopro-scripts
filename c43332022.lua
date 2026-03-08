--ジュラック・ガリム
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。对方可以选1张手卡丢弃让这个效果无效。没丢弃的场合，把让这张卡破坏的怪兽破坏。
function c43332022.initial_effect(c)
	-- 效果原文内容：①：这张卡被战斗破坏送去墓地的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43332022,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c43332022.descon)
	e1:SetTarget(c43332022.destg)
	e1:SetOperation(c43332022.desop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查此卡是否因战斗破坏而进入墓地
function c43332022.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面作用：设置连锁处理信息，若对方没有手牌可丢弃则将破坏对象怪兽加入处理目标
function c43332022.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetReasonCard()
	-- 规则层面作用：判断破坏此卡的怪兽是否与本次战斗相关且对方没有可丢弃的手牌
	if tc:IsRelateToBattle() and not Duel.IsExistingMatchingCard(Card.IsDiscardable,1-tp,LOCATION_HAND,0,1,nil) then
		-- 规则层面作用：设置连锁操作信息，将目标怪兽加入破坏处理列表
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	end
end
-- 效果原文内容：对方可以选1张手卡丢弃让这个效果无效。没丢弃的场合，把让这张卡破坏的怪兽破坏。
function c43332022.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetReasonCard()
	if not tc:IsRelateToBattle() then return end
	-- 规则层面作用：判断对方是否有可丢弃的手牌并询问是否丢弃
	if Duel.IsExistingMatchingCard(Card.IsDiscardable,1-tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(1-tp,aux.Stringid(43332022,1)) then  --"是否要丢弃手牌？"
		-- 规则层面作用：让对方丢弃一张手牌
		Duel.DiscardHand(1-tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	-- 规则层面作用：若对方未丢弃手牌则破坏让此卡破坏的怪兽
	else Duel.Destroy(tc,REASON_EFFECT) end
end
