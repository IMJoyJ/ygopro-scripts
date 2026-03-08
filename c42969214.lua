--アイアイアン
-- 效果：
-- 1回合1次，自己的主要阶段时可以让这张卡的攻击力上升400。这个效果发动的回合，这张卡不能攻击。
function c42969214.initial_effect(c)
	-- 效果原文内容：1回合1次，自己的主要阶段时可以让这张卡的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42969214,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c42969214.cost)
	e1:SetOperation(c42969214.operation)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查此卡本回合是否已经攻击过，若未攻击则设置此卡不能攻击的效果。
function c42969214.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 效果原文内容：这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 规则层面操作：使此卡攻击力上升400点。
function c42969214.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：1回合1次，自己的主要阶段时可以让这张卡的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
