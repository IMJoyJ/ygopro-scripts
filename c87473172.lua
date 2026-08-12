--火炎鳥
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次自己场上的鸟兽族怪兽被破坏，这张卡攻击力上升500。
function c87473172.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，每次自己场上的鸟兽族怪兽被破坏，这张卡攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87473172,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c87473172.atkcon)
	e1:SetOperation(c87473172.atkop)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查被破坏的怪兽是否原本为自己场上表侧表示的鸟兽族怪兽
function c87473172.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and bit.band(c:GetPreviousRaceOnField(),RACE_WINDBEAST)~=0
end
-- 触发条件：被破坏的卡片中存在至少1张满足过滤条件的怪兽
function c87473172.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87473172.cfilter,1,nil,tp)
end
-- 效果处理：若此卡仍在场上表侧表示存在，则使其攻击力上升500
function c87473172.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
