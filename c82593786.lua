--タスケルトン
-- 效果：
-- 怪兽进行战斗的战斗步骤时，把墓地的这张卡从游戏中除外才能发动。那只怪兽的攻击无效。这个效果在对方回合也能发动。「骨猪一掷」的效果在决斗中只能使用1次。
function c82593786.initial_effect(c)
	-- 怪兽进行战斗的战斗步骤时，把墓地的这张卡从游戏中除外才能发动。那只怪兽的攻击无效。这个效果在对方回合也能发动。「骨猪一掷」的效果在决斗中只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82593786,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,82593786+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c82593786.condition)
	-- 设置发动代价为将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c82593786.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：必须在有怪兽进行攻击时才能发动
function c82593786.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否存在攻击怪兽
	return Duel.GetAttacker()~=nil
end
-- 定义效果处理：使当前的攻击无效
function c82593786.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该怪兽的攻击
	Duel.NegateAttack()
end
