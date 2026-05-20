--ジュラック・ティラヌス
-- 效果：
-- 可以把自己场上存在的1只恐龙族怪兽解放，这张卡的攻击力上升500。这张卡战斗破坏对方怪兽送去墓地时，这张卡的攻击力上升300。
function c62701967.initial_effect(c)
	-- 可以把自己场上存在的1只恐龙族怪兽解放，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62701967,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(500)
	e1:SetCost(c62701967.atkcost)
	e1:SetOperation(c62701967.operation)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽送去墓地时，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62701967,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetLabel(300)
	e2:SetCondition(c62701967.atkcon)
	e2:SetOperation(c62701967.operation)
	c:RegisterEffect(e2)
end
-- 检查并执行解放自己场上1只恐龙族怪兽的代价
function c62701967.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除自身以外的1只恐龙族怪兽可以解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_DINOSAUR) end
	-- 选择自己场上除自身以外的1只恐龙族怪兽
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,e:GetHandler(),RACE_DINOSAUR)
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 使这张卡的攻击力上升对应数值
function c62701967.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升500 / 这张卡的攻击力上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 检查此卡是否战斗破坏对方怪兽并送去墓地
function c62701967.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsFaceup() and c:IsRelateToBattle()
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
