--死力のタッグ・チェンジ
-- 效果：
-- 自己场上表侧攻击表示存在的怪兽被战斗破坏的伤害计算时，可以把那次战斗发生的对自己的战斗伤害变成0，那次伤害步骤结束时从手卡把1只4星以下的战士族怪兽特殊召唤。
function c34149830.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧攻击表示存在的怪兽被战斗破坏的伤害计算时，可以把那次战斗发生的对自己的战斗伤害变成0，那次伤害步骤结束时从手卡把1只4星以下的战士族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34149830,0))  --"战斗伤害变成0"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c34149830.condition)
	e2:SetTarget(c34149830.target)
	e2:SetOperation(c34149830.operation)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：攻击怪兽为表侧攻击表示且攻击力小于等于对方怪兽的攻击力
function c34149830.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if tc:IsControler(1-tp) then
		-- 获取攻击怪兽的战斗目标
		tc=Duel.GetAttackTarget()
		-- 获取攻击目标的攻击怪兽
		bc=Duel.GetAttacker()
	end
	return tc and bc and not tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
		and tc:IsPosition(POS_FACEUP_ATTACK) and tc:GetAttack()<=bc:GetAttack()
end
-- 筛选手卡中4星以下的战士族且可以特殊召唤的怪兽
function c34149830.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动效果：当前卡未在连锁中且手卡存在满足条件的怪兽
function c34149830.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c34149830.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
-- 发动效果：使自己受到的战斗伤害变为0，并在伤害步骤结束时特殊召唤怪兽
function c34149830.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己受到的战斗伤害变为0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 在伤害步骤结束时触发特殊召唤效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e2:SetOperation(c34149830.spop)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 处理伤害步骤结束后的特殊召唤
function c34149830.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c34149830.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
