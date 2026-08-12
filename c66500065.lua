--地竜星－ヘイカン
-- 效果：
-- 「地龙星-狴犴」的①的效果1回合只能使用1次。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「地龙星-狴犴」以外的1只「龙星」怪兽守备表示特殊召唤。
-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
-- ③：这张卡为同调素材的同调怪兽不会被战斗破坏。
function c66500065.initial_effect(c)
	-- 「地龙星-狴犴」的①的效果1回合只能使用1次。①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「地龙星-狴犴」以外的1只「龙星」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66500065,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,66500065)
	e1:SetCondition(c66500065.condition)
	e1:SetTarget(c66500065.target)
	e1:SetOperation(c66500065.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c66500065.sccon)
	e2:SetTarget(c66500065.sctg)
	e2:SetOperation(c66500065.scop)
	c:RegisterEffect(e2)
	-- ③：这张卡为同调素材的同调怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c66500065.indcon)
	e3:SetOperation(c66500065.indop)
	c:RegisterEffect(e3)
end
-- 检查发动条件：这张卡在自己场上被战斗或效果破坏并送去墓地。
function c66500065.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 过滤卡组中除「地龙星-狴犴」以外、可以表侧守备表示特殊召唤的「龙星」怪兽。
function c66500065.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(66500065) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查怪兽区域是否有空位，以及卡组中是否存在满足条件的怪兽，并设置特殊召唤的操作信息。
function c66500065.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足过滤条件的「龙星」怪兽。
		and Duel.IsExistingMatchingCard(c66500065.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只「龙星」怪兽以表侧守备表示特殊召唤。
function c66500065.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「龙星」怪兽。
	local g=Duel.SelectMatchingCard(tp,c66500065.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查同调召唤效果的发动条件：必须在对方的主要阶段或战斗阶段。
function c66500065.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合（若为自己回合则不能发动）。
	if Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 过滤自己场上的「龙星」怪兽（作为同调素材）。
function c66500065.mfilter(c)
	return c:IsSetCard(0x9e)
end
-- 检查额外卡组中是否存在可以使用自己场上「龙星」怪兽作为素材进行同调召唤的怪兽，并设置特殊召唤的操作信息。
function c66500065.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上所有的「龙星」怪兽作为同调素材组。
		local mg=Duel.GetMatchingGroup(c66500065.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组中是否存在仅以这些「龙星」怪兽为素材可以进行同调召唤的怪兽。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设置连锁处理的操作信息，表示该效果会从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择额外卡组中1只可以同调召唤的怪兽，并以自己场上的「龙星」怪兽为素材进行同调召唤。
function c66500065.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有的「龙星」怪兽作为同调素材。
	local mg=Duel.GetMatchingGroup(c66500065.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中所有可以使用这些素材进行同调召唤的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要进行同调召唤（特殊召唤）的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 使用指定的「龙星」怪兽作为素材，对选定的怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 检查是否作为同调素材送去墓地。
function c66500065.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 效果处理：给以此卡为素材同调召唤的怪兽赋予“不会被战斗破坏”的效果。
function c66500065.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：这张卡为同调素材的同调怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66500065,1))  --"「地龙星-狴犴」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
