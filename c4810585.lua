--戦華史略－長坂之雄
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：自己的「战华」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：对方战斗阶段开始时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。这个回合，对方不能选择「战华」怪兽作为攻击对象。
-- ③：对方怪兽的攻击宣言时，把墓地的这张卡除外才能发动。从卡组把1只「战华」怪兽特殊召唤。
function c4810585.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	c:RegisterEffect(e0)
	-- ①：自己的「战华」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c4810585.aclimit)
	e1:SetCondition(c4810585.actcon)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段开始时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。这个回合，对方不能选择「战华」怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4810585,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,4810585)
	e2:SetCondition(c4810585.atcon)
	e2:SetCost(c4810585.atcost)
	e2:SetOperation(c4810585.atop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽的攻击宣言时，把墓地的这张卡除外才能发动。从卡组把1只「战华」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4810585,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,4810585)
	e3:SetCondition(c4810585.spcon)
	-- 为③效果设置发动代价：把墓地中的这张卡除外（才能发动）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c4810585.sptg)
	e3:SetOperation(c4810585.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽是否表侧表示、属于「战华」系列且控制者为己方，用于①的“自己的「战华」怪兽进行战斗”的判定。
function c4810585.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsControler(tp)
end
-- 限制函数：被禁止发动的效果必须满足“是魔法·陷阱卡的发动”这一条件（re:IsHasType(EFFECT_TYPE_ACTIVATE)），即只禁止魔法·陷阱卡的发动。
function c4810585.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ①效果的生效条件：自己的「战华」怪兽正在进行战斗（攻击怪兽或攻击目标中存在己方表侧表示的战华怪兽）。
function c4810585.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 取得当前攻击宣言的怪兽（攻击方）。
	local a=Duel.GetAttacker()
	-- 取得当前被攻击的怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	return (a and c4810585.cfilter(a,tp)) or (d and c4810585.cfilter(d,tp))
end
-- ②效果的发动条件：对方战斗阶段开始时（当前回合玩家为对手）。
function c4810585.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是对方（1-tp）时条件成立，即仅在对方回合的战斗阶段开始时。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动代价：将魔法与陷阱区域表侧表示的这张卡送去墓地。通过检查卡是否可送墓且效果可用，然后执行送墓。
function c4810585.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡以“代价”原因送去墓地（实现②的发动cost）。
	Duel.SendtoGrave(c,REASON_COST)
end
-- ②效果处理：生成一个持续到结束阶段的永续效果，让对手不能选择己方表侧表示的「战华」怪兽作为攻击对象。
function c4810585.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能选择「战华」怪兽作为攻击对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c4810585.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能选择战华怪兽为攻击对象”的效果注册到场上，持续到回合结束，使对方不能选择「战华」怪兽作为攻击对象。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击对象限制的判定：怪兽必须是表侧表示的「战华」怪兽，即该效果只保护这类怪兽不被选为攻击对象。
function c4810585.atlimit(e,c)
	return c:IsSetCard(0x137) and c:IsFaceup()
end
-- 特召筛选：从卡组中选出属于「战华」系列且能够被当前效果特殊召唤的怪兽。
function c4810585.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件：对方回合（对方怪兽的攻击宣言时，当前回合玩家不是效果发动方）。
function c4810585.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是tp（即对方回合）时条件成立。
	return tp~=Duel.GetTurnPlayer()
end
-- ③效果的发动目标（处理前检查）：己方主要怪兽区有空位，且卡组中存在可特殊召唤的「战华」怪兽。
function c4810585.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 当处于发动合法性检查时，先确认己方主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认卡组中存在至少1只满足特召条件的「战华」怪兽（用于发动合法性判定）。
		and Duel.IsExistingMatchingCard(c4810585.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行特殊召唤（处理时从卡组特召1只怪兽），供相关效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选1只「战华」怪兽，以表侧攻击表示特殊召唤到自己场上（若此时没有空位则不处理）。
function c4810585.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若己方主要怪兽区没有空位，则处理中止（不特召）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家弹出选择提示，要求其选择要特殊召唤的「战华」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「战华」怪兽（特殊召唤对象）。
	local g=Duel.SelectMatchingCard(tp,c4810585.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
