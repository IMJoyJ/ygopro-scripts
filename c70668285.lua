--光天使ソード
-- 效果：
-- 1回合1次，把手卡1只名字带有「光天使」的怪兽送去墓地才能发动。这张卡的攻击力直到结束阶段时上升送去墓地的怪兽的原本攻击力数值。
function c70668285.initial_effect(c)
	-- 1回合1次，把手卡1只名字带有「光天使」的怪兽送去墓地才能发动。这张卡的攻击力直到结束阶段时上升送去墓地的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70668285,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c70668285.atkcost)
	e1:SetOperation(c70668285.atkop)
	c:RegisterEffect(e1)
end
-- 过滤手卡中原本攻击力大于0且可以作为代价送去墓地的「光天使」怪兽
function c70668285.cfilter(c)
	return c:IsSetCard(0x86) and c:GetBaseAttack()>0 and c:IsAbleToGraveAsCost()
end
-- 检查并执行发动代价：将手卡1只「光天使」怪兽送去墓地，并记录其原本攻击力
function c70668285.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只满足条件的「光天使」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c70668285.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足条件的「光天使」怪兽
	local g=Duel.SelectMatchingCard(tp,c70668285.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetBaseAttack())
end
-- 效果处理：若此卡在场上表侧表示存在，则其攻击力直到结束阶段上升送去墓地怪兽的原本攻击力数值
function c70668285.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时上升送去墓地的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
