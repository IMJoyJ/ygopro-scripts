--エクスチェンジ
-- 效果：
-- 双方玩家把手卡公开，各自选1张对方的卡加入自己手卡。
function c5556668.initial_effect(c)
	-- 双方玩家把手卡公开，各自选1张对方的卡加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5556668.target)
	e1:SetOperation(c5556668.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方手牌数量大于0，且自己手牌中存在除这张卡以外的卡
function c5556668.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 检查自己手牌中是否存在至少1张除这张卡（手札对换）以外的卡
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
-- 效果处理：双方公开手牌，各自选择对方的1张手牌加入自己手牌
function c5556668.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己当前的所有手牌
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 获取对方当前的所有手牌
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 向自己公开对方的所有手牌
	Duel.ConfirmCards(tp,g2)
	-- 向对方公开自己的所有手牌
	Duel.ConfirmCards(1-tp,g1)
	-- 提示自己选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local ag1=g2:Select(tp,1,1,nil)
	-- 提示对方选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local ag2=g1:Select(1-tp,1,1,nil)
	-- 将自己选中的对方手牌加入自己的手牌
	Duel.SendtoHand(ag1,tp,REASON_EFFECT)
	-- 将对方选中的自己手牌加入对方的手牌
	Duel.SendtoHand(ag2,1-tp,REASON_EFFECT)
end
