--アマゾネス訓練生
-- 效果：
-- 这张卡战斗破坏的怪兽不送去墓地回到持有者卡组最下面。这张卡战斗破坏对方怪兽的场合，这张卡的攻击力上升200。
function c89567993.initial_effect(c)
	-- 这张卡战斗破坏的怪兽不送去墓地回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽的场合，这张卡的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89567993,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c89567993.atkcon)
	e2:SetOperation(c89567993.atkop)
	c:RegisterEffect(e2)
end
-- 判断自身是否表侧表示存在且仍与本次战斗相关联
function c89567993.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle()
end
-- 若自身表侧表示且与战斗关联，则为自身施加攻击力上升200的效果
function c89567993.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToBattle() then
		-- 这张卡的攻击力上升200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
