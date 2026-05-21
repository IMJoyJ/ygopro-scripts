--機甲忍者アクア
-- 效果：
-- 对方怪兽的直接攻击宣言时，自己墓地有这张卡以外的名字带有「忍者」的怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。把1只攻击怪兽的攻击无效。
function c96427353.initial_effect(c)
	-- 对方怪兽的直接攻击宣言时，自己墓地有这张卡以外的名字带有「忍者」的怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。把1只攻击怪兽的攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96427353,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c96427353.condition)
	-- 设置发动代价为将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c96427353.target)
	e1:SetOperation(c96427353.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：名字带有「忍者」的怪兽卡
function c96427353.cfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER)
end
-- 发动条件：对方回合的直接攻击宣言时，且自己墓地存在这张卡以外的「忍者」怪兽
function c96427353.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且攻击对象为空（即直接攻击）
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==nil
		-- 检查自己墓地是否存在至少1张除这张卡以外的名字带有「忍者」的怪兽
		and Duel.IsExistingMatchingCard(c96427353.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
end
-- 效果发动时的目标选择：获取攻击怪兽并将其设为效果对象
function c96427353.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为效果处理的对象
	Duel.SetTargetCard(tg)
end
-- 效果处理：无效该怪兽的攻击
function c96427353.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
