--フォトン・チャージマン
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力直到下次的自己的准备阶段时变成原本攻击力的2倍。这个效果发动的回合，这张卡不能攻击。
function c2618045.initial_effect(c)
	-- 效果原文：1回合1次，自己的主要阶段时才能发动。这张卡的攻击力直到下次的自己的准备阶段时变成原本攻击力的2倍。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2618045,0))  --"攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c2618045.cost)
	e1:SetOperation(c2618045.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡在本回合是否已经攻击过，若未攻击则设置此卡在效果发动的回合不能攻击
function c2618045.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 效果原文：1回合1次，自己的主要阶段时才能发动。这张卡的攻击力直到下次的自己的准备阶段时变成原本攻击力的2倍。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 若此卡在效果发动时仍然在场且表侧表示，则将其攻击力临时变为原本攻击力的2倍，并在下次准备阶段重置
function c2618045.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 效果原文：这张卡的攻击力直到下次的自己的准备阶段时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_STANDBY,2)
		c:RegisterEffect(e1)
	end
end
