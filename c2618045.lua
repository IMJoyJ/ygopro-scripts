--フォトン・チャージマン
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力直到下次的自己的准备阶段时变成原本攻击力的2倍。这个效果发动的回合，这张卡不能攻击。
function c2618045.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力直到下次的自己的准备阶段时变成原本攻击力的2倍。这个效果发动的回合，这张卡不能攻击。
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
-- 发动代价检查：确认这张卡本回合没有进行过攻击宣言；若满足，则给这张卡附加一个无法被无效的“不能攻击”效果，直到回合结束。
function c2618045.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 效果处理：若这张卡仍与效果关联且表侧表示存在，则将其攻击力设置为原本攻击力的2倍，该变化持续到下次自己的准备阶段。
function c2618045.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到下次的自己的准备阶段时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_STANDBY,2)
		c:RegisterEffect(e1)
	end
end
