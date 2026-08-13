--水竜星－ビシキ
-- 效果：
-- 「水龙星-赑屃」的①的效果1回合只能使用1次。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「水龙星-赑屃」以外的1只「龙星」怪兽攻击表示特殊召唤。
-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
-- ③：这张卡为同调素材的同调怪兽不受陷阱卡的效果影响。
function c2095764.initial_effect(c)
	-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「水龙星-赑屃」以外的1只「龙星」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2095764,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,2095764)
	e1:SetCondition(c2095764.condition)
	e1:SetTarget(c2095764.target)
	e1:SetOperation(c2095764.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c2095764.sccon)
	e2:SetTarget(c2095764.sctg)
	e2:SetOperation(c2095764.scop)
	c:RegisterEffect(e2)
	-- ③：这张卡为同调素材的同调怪兽不受陷阱卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c2095764.immcon)
	e3:SetOperation(c2095764.immop)
	c:RegisterEffect(e3)
end
-- ①的发动条件：判定这张卡是被战斗或效果破坏并送去墓地，且破坏前在自己场上由自己控制。
function c2095764.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- ①的检索条件：选择卡组中卡名含「龙星」字段、不是「水龙星-赑屃」且可以攻击表示特殊召唤的怪兽。
function c2095764.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(2095764) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①的发动合法性检查：自己主要怪兽区有空位，且卡组存在符合条件的「龙星」怪兽。
function c2095764.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足c2095764.filter的「龙星」怪兽。
		and Duel.IsExistingMatchingCard(c2095764.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：从卡组将1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：从卡组选择1只符合条件的「龙星」怪兽攻击表示特殊召唤。
function c2095764.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己主要怪兽区没有空位，则效果不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张符合filter的「龙星」怪兽。
	local g=Duel.SelectMatchingCard(tp,c2095764.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
-- ②的发动条件：仅在对方回合的主要阶段（主1/主2）及战斗阶段才能发动。
function c2095764.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是自己时不能发动，确保是对方回合。
	if Duel.GetTurnPlayer()==tp then return false end
	-- 取得当前阶段，用于判断是否处于对方的主要阶段或战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- ②的素材筛选：选择自己场上所有卡名含「龙星」字段的怪兽作为同调素材。
function c2095764.mfilter(c)
	return c:IsSetCard(0x9e)
end
-- ②的发动合法性检查：额外卡组存在能用自己场上「龙星」怪兽作为素材进行同调召唤的怪兽。
function c2095764.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上所有「龙星」怪兽组成的候选素材集合。
		local mg=Duel.GetMatchingGroup(c2095764.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组中是否存在能用该素材集合进行同调召唤的怪兽。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设置本次效果的操作信息：从额外卡组特殊召唤1只同调怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②的效果处理：选择额外卡组的同调怪兽，并只用自己场上的「龙星」怪兽作为素材进行同调召唤。
function c2095764.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取自己场上所有「龙星」怪兽作为同调素材。
	local mg=Duel.GetMatchingGroup(c2095764.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中所有能用该素材组进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 给玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤手续，将选择的同调怪兽用自己场上的「龙星」怪兽群作为素材进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- ③的触发条件：这张卡作为同调素材被使用（reason为REASON_SYNCHRO）。
function c2095764.immcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- ③的效果处理：给那次同调召唤出的怪兽赋予对陷阱卡效果免疫的效果。
function c2095764.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：这张卡为同调素材的同调怪兽不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2095764,1))  --"「水龙星-赑屃」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c2095764.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
-- 免疫过滤函数：仅免疫类型为陷阱卡的效果（即陷阱卡的效果不适用）。
function c2095764.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
