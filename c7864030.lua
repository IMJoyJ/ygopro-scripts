--超重武者タイマ－2
-- 效果：
-- ①：对方怪兽的攻击宣言时自己墓地没有魔法·陷阱卡存在的场合，把这张卡从手卡送去墓地，以自己场上1只「超重武者」怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
-- ②：1回合1次，对方怪兽的攻击宣言时才能发动。攻击对象转移为这张卡进行伤害计算。
-- ③：这张卡不会被战斗破坏。
function c7864030.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时自己墓地没有魔法·陷阱卡存在的场合，把这张卡从手卡送去墓地，以自己场上1只「超重武者」怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c7864030.condition1)
	e1:SetCost(c7864030.cost)
	e1:SetTarget(c7864030.target1)
	e1:SetOperation(c7864030.operation1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方怪兽的攻击宣言时才能发动。攻击对象转移为这张卡进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c7864030.condition2)
	e2:SetOperation(c7864030.operation2)
	c:RegisterEffect(e2)
	-- ③：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件函数：对方怪兽攻击宣言时，且自己墓地没有魔法·陷阱卡存在
function c7864030.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方，且自己墓地是否存在魔法·陷阱卡
	return Duel.GetTurnPlayer()~=tp and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的代价值函数：将手牌的这张卡送去墓地
function c7864030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：场上表侧表示的「超重武者」怪兽
function c7864030.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果①的对象选择与发动准备函数
function c7864030.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7864030.filter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示「超重武者」怪兽
	if chk==0 then return Duel.IsExistingTarget(c7864030.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「超重武者」怪兽作为对象
	Duel.SelectTarget(tp,c7864030.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理函数：将攻击对象转移为选择的怪兽并进行伤害计算
function c7864030.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取当前进行攻击宣言的攻击怪兽
		local at=Duel.GetAttacker()
		if at:IsAttackable() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
			-- 强制令攻击怪兽与选择的对象怪兽进行伤害计算
			Duel.CalculateDamage(at,tc)
		end
	end
end
-- 效果②的发动条件函数：对方怪兽攻击宣言时，且攻击对象不是这张卡
function c7864030.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方，且当前攻击对象不是这张卡自身
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()~=e:GetHandler()
end
-- 效果②的处理函数：将攻击对象转移为这张卡并进行伤害计算
function c7864030.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 获取当前进行攻击宣言的攻击怪兽
		local at=Duel.GetAttacker()
		if at:IsAttackable() and not at:IsImmuneToEffect(e) then
			-- 强制令攻击怪兽与这张卡进行伤害计算
			Duel.CalculateDamage(at,c)
		end
	end
end
