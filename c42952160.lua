--冥府の合わせ鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方的攻击·效果让自己受到伤害时才能发动。受到的伤害种类的以下效果适用。
-- ●战斗：把持有那个数值以下的攻击力的1只怪兽从自己墓地特殊召唤，那次伤害步骤结束后战斗阶段结束。
-- ●效果：给与对方那个数值2倍的伤害。
local s,id,o=GetID()
-- 创建两个效果，分别对应战斗伤害和效果伤害的处理
function s.initial_effect(c)
	-- ●战斗：把持有那个数值以下的攻击力的1只怪兽从自己墓地特殊召唤，那次伤害步骤结束后战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"战斗"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ●效果：给与对方那个数值2倍的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"效果"
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(s.dacon)
	e2:SetOperation(s.daop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方攻击造成的战斗伤害且自己为伤害接受者
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方攻击造成的战斗伤害且自己为伤害接受者
	return ep==tp and Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤墓地攻击力低于或等于指定值且可特殊召唤的怪兽
function s.filter(c,v,e,tp)
	return c:IsAttackBelow(v) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的处理目标和信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件
	if chk==0 then return r&REASON_EFFECT>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,ev,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作并注册战斗阶段结束效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否有满足条件的墓地怪兽可特殊召唤
	local ss=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,nil,ev,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,ev,e,tp)
	-- 若特殊召唤成功则注册战斗阶段结束效果
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 注册战斗阶段结束跳过效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetOperation(s.skipop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 将战斗阶段结束跳过效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 战斗阶段结束时跳过对方的战斗阶段
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合玩家的战斗阶段
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
-- 判断是否为对方效果造成的伤害且自己为伤害接受者
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return false end
	return r&REASON_EFFECT>0 and rp==1-tp
end
-- 执行给对方造成两倍伤害的效果
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方造成指定数值两倍的伤害
	Duel.Damage(1-tp,ev*2,REASON_EFFECT)
end
