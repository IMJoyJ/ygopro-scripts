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
-- 判定发动条件：当前战斗中的己方表侧攻击怪兽将要被战斗破坏（不持有不会被战斗破坏的效果，且攻击力不高于战斗对象）。
function c34149830.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前攻击怪兽作为战斗中的攻击方。
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if tc:IsControler(1-tp) then
		-- 当攻击方为对方怪兽时，把己方被攻击的怪兽设为战斗对象。
		tc=Duel.GetAttackTarget()
		-- 当攻击方为对方怪兽时，把对方攻击怪兽设为战斗对象。
		bc=Duel.GetAttacker()
	end
	return tc and bc and not tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
		and tc:IsPosition(POS_FACEUP_ATTACK) and tc:GetAttack()<=bc:GetAttack()
end
-- 定义特殊召唤的筛选条件：手卡中4星以下、战士族且可以被特殊召唤的怪兽。
function c34149830.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时判定：该卡没有处于连锁串中，且我方手卡存在满足特殊召唤条件的怪兽。
function c34149830.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查我方手卡是否存在至少1张满足spfilter条件的怪兽。
		and Duel.IsExistingMatchingCard(c34149830.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
-- 效果处理：先给己方附加避免战斗伤害的效果，再在伤害步骤结束时执行从手卡特召怪兽的效果。
function c34149830.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 可以把那次战斗发生的对自己的战斗伤害变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	-- 将避免己方战斗伤害的效果注册给当前玩家。
	Duel.RegisterEffect(e1,tp)
	-- 那次伤害步骤结束时从手卡把1只4星以下的战士族怪兽特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e2:SetOperation(c34149830.spop)
	-- 将伤害步骤结束时执行特殊召唤的效果注册到当前场上。
	Duel.RegisterEffect(e2,tp)
end
-- 伤害步骤结束时的处理：若我方主要怪兽区有空位，则从手牌选择1只符合条件的战士族怪兽特殊召唤。
function c34149830.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方主要怪兽区是否有空位，若无空位则无法进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张满足spfilter条件（4星以下战士族且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c34149830.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
