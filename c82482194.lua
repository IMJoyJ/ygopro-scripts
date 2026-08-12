--ミレニアム・スコーピオン
-- 效果：
-- 每次这张卡战斗破坏对方场上1只怪兽送去墓地的场合，这张卡攻击力上升500。
function c82482194.initial_effect(c)
	-- 每次这张卡战斗破坏对方场上1只怪兽送去墓地的场合，这张卡攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82482194,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c82482194.atcon)
	e1:SetOperation(c82482194.atop)
	c:RegisterEffect(e1)
end
-- 过滤被自身战斗破坏并送去墓地的怪兽
function c82482194.filter(c,rc)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:GetReasonCard()==rc
end
-- 检查被破坏的怪兽中是否存在被自身战斗破坏并送去墓地的怪兽，作为效果发动条件
function c82482194.atcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82482194.filter,1,nil,e:GetHandler())
end
-- 若自身仍在场上表侧表示存在，则使其攻击力上升500
function c82482194.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
