--CNo.96 ブラック・ストーム
-- 效果：
-- 暗属性3星怪兽×4
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害让对方也承受。
-- ②：这张卡有「No.96 黑雾」在作为超量素材的场合，得到以下效果。
-- ●这张卡和对方怪兽进行战斗的攻击宣言时1次，把这张卡1个超量素材取除才能发动。那只对方怪兽的攻击力变成0，这张卡的攻击力上升那只对方怪兽的原本攻击力数值。
function c77205367.initial_effect(c)
	-- 添加超量召唤手续：暗属性3星怪兽×4。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,4)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡的战斗发生的对自己的战斗伤害让对方也承受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
	-- ②：这张卡有「No.96 黑雾」在作为超量素材的场合，得到以下效果。●这张卡和对方怪兽进行战斗的攻击宣言时1次，把这张卡1个超量素材取除才能发动。那只对方怪兽的攻击力变成0，这张卡的攻击力上升那只对方怪兽的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77205367,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c77205367.atkcon)
	e3:SetCost(c77205367.atkcost)
	e3:SetTarget(c77205367.atktg)
	e3:SetOperation(c77205367.atkop)
	c:RegisterEffect(e3)
end
-- 设定该卡为「No.」怪兽，其卡号为96。
aux.xyz_number[77205367]=96
-- 检查这张卡是否有「No.96 黑雾」作为超量素材，作为效果发动的条件。
function c77205367.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,55727845)
end
-- 效果发动代价：取除这张卡的1个超量素材。
function c77205367.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查是否为这张卡与对方怪兽进行战斗的攻击宣言时，并确认战斗对象。
function c77205367.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取当前进行攻击宣言的怪兽。
		local a=Duel.GetAttacker()
		-- 获取当前被攻击的目标怪兽。
		local at=Duel.GetAttackTarget()
		return ((a==c and at and at:IsFaceup() and at:GetAttack()>0) or (at==c and a:GetAttack()>0))
			and not e:GetHandler():IsStatus(STATUS_CHAINING)
	end
	-- 将与这张卡进行战斗的对方怪兽设为效果处理的对象。
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
-- 效果处理：使进行战斗的对方怪兽攻击力变成0，并使这张卡的攻击力上升该怪兽的原本攻击力数值。
function c77205367.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		local atk=tc:GetBaseAttack()
		-- 那只对方怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这张卡的攻击力上升那只对方怪兽的原本攻击力数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
