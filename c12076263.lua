--ゼンマイドッグ
-- 效果：
-- 自己的主要阶段时才能发动。直到结束阶段时这张卡的等级上升2星，攻击力上升600。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c12076263.initial_effect(c)
	-- 自己的主要阶段时才能发动。直到结束阶段时这张卡的等级上升2星，攻击力上升600。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12076263,0))  --"等级攻击上升"
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c12076263.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时执行的操作函数
function c12076263.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 直到结束阶段时这张卡的攻击力上升600
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(600)
		c:RegisterEffect(e1)
		-- 直到结束阶段时这张卡的等级上升2星
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e2:SetValue(2)
		c:RegisterEffect(e2)
	end
end
