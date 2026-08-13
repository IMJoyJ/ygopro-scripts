--魔竜星－トウテツ
-- 效果：
-- 「魔龙星-饕餮」的①的效果1回合只能使用1次。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「魔龙星-饕餮」以外的1只「龙星」怪兽守备表示特殊召唤。
-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
-- ③：这张卡为同调素材的同调怪兽不能把控制权变更。
function c99946920.initial_effect(c)
	-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「魔龙星-饕餮」以外的1只「龙星」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99946920,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,99946920)
	e1:SetCondition(c99946920.condition)
	e1:SetTarget(c99946920.target)
	e1:SetOperation(c99946920.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c99946920.sccon)
	e2:SetTarget(c99946920.sctg)
	e2:SetOperation(c99946920.scop)
	c:RegisterEffect(e2)
	-- ③：这张卡为同调素材的同调怪兽不能把控制权变更。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c99946920.atkcon)
	e3:SetOperation(c99946920.atkop)
	c:RegisterEffect(e3)
end
-- ①的发动条件：这张卡被战斗或效果破坏并送去墓地，且破坏前在己方场上并归己方控制。
function c99946920.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 筛选可特殊召唤的卡：卡组中拥有「龙星」字段、卡名不是「魔龙星-饕餮」、且可以表侧守备表示特殊召唤的怪兽。
function c99946920.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(99946920) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①的发动时点检查：确认自己场上有空余的怪兽区，且卡组中存在满足特殊召唤条件的「龙星」怪兽，才能发动。
function c99946920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足c99946920.filter条件的「龙星」怪兽。
		and Duel.IsExistingMatchingCard(c99946920.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息为“从卡组特殊召唤1只怪兽”，以便其他卡（如星尘龙）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：若自己场上仍有空位，从卡组选择1只符合条件的「龙星」怪兽，以表侧守备表示特殊召唤。
function c99946920.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方场上存在空余怪兽区；没有空位则本次处理不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1张满足c99946920.filter的卡（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c99946920.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧守备表示特殊召唤到己方场上（sumtype为0，不视为同调召唤）。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②的发动条件：当前为对方回合，且处于主要阶段1、战斗阶段或主要阶段2。
function c99946920.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家是自己，则不是对方回合，②不能发动。
	if Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前阶段，用于判断是否处于对方的主要阶段或战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 筛选自己场上所有「龙星」怪兽，作为同调召唤的候选素材。
function c99946920.mfilter(c)
	return c:IsSetCard(0x9e)
end
-- ②的发动时点检查：收集自己场上所有「龙星」怪兽作为候选素材，并确认额外卡组中存在能用它们同调召唤的怪兽。
function c99946920.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上所有「龙星」怪兽，作为同调召唤的候选素材。
		local mg=Duel.GetMatchingGroup(c99946920.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组中是否存在至少1只能够用上述「龙星」素材进行同调召唤的同调怪兽。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设置本次效果的操作信息为“从额外卡组特殊召唤1只怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②的效果处理：从自己场上的「龙星」怪兽中选取素材，从额外卡组选择1只同调怪兽进行同调召唤。
function c99946920.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取自己场上所有「龙星」怪兽，作为同调素材。
	local mg=Duel.GetMatchingGroup(c99946920.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中所有能用这些「龙星」素材进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 显示选择提示：“请选择要特殊召唤的卡”，让玩家选择要同调召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤：用自己场上的「龙星」怪兽为素材，将选择的同调怪兽从额外卡组特殊召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- ③的触发条件：这张卡被用作同调召唤的素材。
function c99946920.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- ③的效果处理：取得以这张卡为素材同调召唤出的怪兽，并为其附加“不能变更控制权”的效果。
function c99946920.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：这张卡为同调素材的同调怪兽不能把控制权变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99946920,1))  --"「魔龙星-饕餮」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
