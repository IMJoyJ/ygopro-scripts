--冥府の合わせ鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方的攻击·效果让自己受到伤害时才能发动。受到的伤害种类的以下效果适用。
-- ●战斗：把持有那个数值以下的攻击力的1只怪兽从自己墓地特殊召唤，那次伤害步骤结束后战斗阶段结束。
-- ●效果：给与对方那个数值2倍的伤害。
local s,id,o=GetID()
-- 定义卡的初始效果注册函数，注册两个分支效果：e1对应对方怪兽攻击造成战斗伤害时发动，可从墓地特召攻击力在伤害数值以下的怪兽并结束战斗阶段；e2对应对方效果造成伤害时发动，给予对方2倍伤害；两个效果共享同名卡1回合1次的发动限制。
function s.initial_effect(c)
	-- ①：对方的攻击·效果让自己受到伤害时才能发动。受到的伤害种类的以下效果适用。●战斗：把持有那个数值以下的攻击力的1只怪兽从自己墓地特殊召唤，那次伤害步骤结束后战斗阶段结束。
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
	-- ①：对方的攻击·效果让自己受到伤害时才能发动。受到的伤害种类的以下效果适用。●效果：给与对方那个数值2倍的伤害。
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
-- 战斗伤害分支的发动条件：受到伤害的玩家必须是本卡控制者自己，且造成战斗伤害的攻击怪兽由对方控制。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真当且仅当受到伤害的玩家是自己，并且攻击怪兽的控制者是对方，从而确认是对方怪兽对自己造成的战斗伤害。
	return ep==tp and Duel.GetAttacker():IsControler(1-tp)
end
-- 定义怪兽筛选函数：选择墓地中攻击力不高于所受伤害数值（v）且可以被当前效果正常特殊召唤的怪兽。
function s.filter(c,v,e,tp)
	return c:IsAttackBelow(v) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 战斗分支的发动时处理：进行发动合法性检查并设置操作信息；合法时告知系统本次效果将从墓地特殊召唤1只怪兽，用于后续的响应检测。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）的合法性判定：若该伤害不属于效果伤害（即战斗伤害），则必须满足自己主要怪兽区有空位且墓地存在符合条件的可特召怪兽；若为效果伤害则无需这两项检查。
	if chk==0 then return r&REASON_EFFECT>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,ev,e,tp) end
	-- 将操作信息设置为从墓地特殊召唤1只怪兽（目标区域为墓地，数量1），使其他卡（如星尘龙、王家长眠之谷等）能正确响应本次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 战斗分支的处理：从自己墓地选择1只攻击力不高于所受伤害数值的怪兽表侧表示特殊召唤；若成功，则注册一个持续效果，在伤害步骤结束时跳过本回合战斗阶段。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使用王家长眠之谷过滤检查墓地是否存在符合条件的可特召怪兽，同时确认自己主要怪兽区有空位（该变量的结果未在后续显式使用）。
	local ss=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,nil,ev,e,tp)
	-- 向玩家发出选择提示，提示内容为‘请选择要特殊召唤的卡’，用于特殊召唤选卡界面的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选出1只攻击力不高于所受伤害数值、且满足特殊召唤条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,ev,e,tp)
	-- 将所选择的怪兽以表侧表示特殊召唤到自己场上；若特殊召唤成功（返回数值>0），才继续执行伤害步骤结束后跳过战斗阶段的效果。
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 那次伤害步骤结束后战斗阶段结束。●效果：给与对方那个数值2倍的伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetOperation(s.skipop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 将该持续效果注册到场上，使效果在伤害步骤结束时触发，执行跳过战斗阶段的处理。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义跳过战斗阶段的处理函数：在伤害步骤结束时，将当前回合玩家的战斗阶段整体跳过，从而结束战斗阶段。
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 直接跳过当前回合玩家的战斗阶段，设置重置条件为战斗阶段结束或战斗步骤，并指定值1表示同时跳过战斗阶段的结束步骤。
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
-- 效果伤害分支的发动条件：受到伤害的玩家是自己，且伤害来源是对方发动的效果（非战斗伤害），即对方的效果让自己受到伤害。
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return false end
	return r&REASON_EFFECT>0 and rp==1-tp
end
-- 效果伤害分支的处理：计算对方应受的伤害为本次所受伤害数值的2倍，并给予对方效果伤害。
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果伤害的方式给予对方玩家本次所受伤害数值2倍的伤害。
	Duel.Damage(1-tp,ev*2,REASON_EFFECT)
end
