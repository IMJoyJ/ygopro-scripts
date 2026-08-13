--アイアイアン
-- 效果：
-- 1回合1次，自己的主要阶段时可以让这张卡的攻击力上升400。这个效果发动的回合，这张卡不能攻击。
function c42969214.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以让这张卡的攻击力上升400。这个效果发动的回合，这张卡不能攻击。
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
-- 该cost函数在检查阶段确认这张卡本回合攻击宣言次数为0；在支付阶段给这张卡注册‘不能攻击’的誓约效果，该效果持续到回合结束且不能被无效。
function c42969214.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果处理时，若这张卡仍表侧表示且与发动效果仍有关联，则给它附加攻击力上升400的增益效果，该增益持续到这张卡离场、变为里侧或被无效等标准重置时。
function c42969214.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 可以让这张卡的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
