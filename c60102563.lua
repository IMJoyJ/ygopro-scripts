--本気ギレパンダ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，每次场上的兽族怪兽被破坏，这张卡攻击力上升500。
function c60102563.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，每次场上的兽族怪兽被破坏，这张卡攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60102563,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c60102563.atkcon)
	e1:SetOperation(c60102563.atkop)
	c:RegisterEffect(e1)
end
-- 过滤被破坏的怪兽：必须是之前位于主要怪兽区且表侧表示，并且其在场上的种族为兽族，即“场上的兽族怪兽被破坏”的判定条件。
function c60102563.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_BEAST)~=0
end
-- 判定条件：破坏的怪兽集合中存在至少1只满足上述兽族条件的怪兽，则效果触发。
function c60102563.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60102563.cfilter,1,nil)
end
-- 效果处理：获取效果持有者这张卡，若其仍表侧表示且与效果处理有联系，则给它注册一个提升500攻击力的效果，该效果在卡片离场等标准重置时机被重置。
function c60102563.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
