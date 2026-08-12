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
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c4810585.sptg)
	e3:SetOperation(c4810585.spop)
	c:RegisterEffect(e3)
end
-- 判断是否为我方的「战华」怪兽
function c4810585.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsControler(tp)
end
-- 判断是否为魔法卡
function c4810585.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为我方的「战华」怪兽参与了战斗
function c4810585.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	return (a and c4810585.cfilter(a,tp)) or (d and c4810585.cfilter(d,tp))
end
-- 判断是否为对方回合
function c4810585.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 将此卡送去墓地作为cost
function c4810585.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将此卡送去墓地
	Duel.SendtoGrave(c,REASON_COST)
end
-- 设置效果，使对方不能选择「战华」怪兽为攻击对象
function c4810585.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果，使对方不能选择「战华」怪兽为攻击对象
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c4810585.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册此效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为「战华」怪兽且表侧表示
function c4810585.atlimit(e,c)
	return c:IsSetCard(0x137) and c:IsFaceup()
end
-- 判断是否为「战华」怪兽且可以特殊召唤
function c4810585.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否为对方回合
function c4810585.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return tp~=Duel.GetTurnPlayer()
end
-- 判断场上是否有足够的位置以及卡组是否存在满足条件的怪兽
function c4810585.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c4810585.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作
function c4810585.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c4810585.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
