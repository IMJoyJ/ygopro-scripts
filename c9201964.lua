--D－フォーチュン
-- 效果：
-- 对方宣言直接攻击时才能发动。把自己墓地存在的1只名字带有「命运英雄」的怪兽从游戏中除外，战斗阶段结束。
function c9201964.initial_effect(c)
	-- 对方宣言直接攻击时才能发动。把自己墓地存在的1只名字带有「命运英雄」的怪兽从游戏中除外，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c9201964.condition)
	e1:SetCost(c9201964.cost)
	e1:SetOperation(c9201964.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：必须在对方宣言直接攻击时才能发动
function c9201964.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且攻击对象为空（即直接攻击）
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()==nil
end
-- 过滤条件：自己墓地中可作为代价除外的「命运英雄」怪兽
function c9201964.cfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义发动代价函数：将自己墓地1只「命运英雄」怪兽除外
function c9201964.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己墓地是否存在至少1只可除外的「命运英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9201964.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c9201964.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外，作为发动效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义效果处理函数：结束战斗阶段
function c9201964.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方的战斗阶段，使战斗阶段结束
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
