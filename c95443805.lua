--霞の谷の祈祷師
-- 效果：
-- 可以让自己场上的这张卡以外的1只怪兽回到手卡，这张卡的攻击力直到结束阶段时上升500。这个效果1回合只能使用1次。
function c95443805.initial_effect(c)
	-- 可以让自己场上的这张卡以外的1只怪兽回到手卡，这张卡的攻击力直到结束阶段时上升500。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95443805,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c95443805.atkcost)
	e1:SetOperation(c95443805.atkop)
	c:RegisterEffect(e1)
end
-- 发动代价：让自己场上这张卡以外的1只怪兽回到手卡
function c95443805.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外、可以作为代价返回手牌的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHandAsCost,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给玩家发送提示信息：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上除这张卡以外的1只怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHandAsCost,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 将选中的怪兽作为发动代价送回手牌
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果处理：使这张卡的攻击力直到结束阶段时上升500
function c95443805.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
