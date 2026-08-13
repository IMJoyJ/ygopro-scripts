--風竜星－ホロウ
-- 效果：
-- 「风龙星-蒲牢」的①的效果1回合只能使用1次。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「风龙星-蒲牢」以外的1只「龙星」怪兽攻击表示特殊召唤。
-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
-- ③：这张卡为同调素材的同调怪兽不受魔法卡的效果影响。
function c35089369.initial_effect(c)
	-- 「风龙星-蒲牢」的①的效果1回合只能使用1次。①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「风龙星-蒲牢」以外的1只「龙星」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35089369,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,35089369)
	e1:SetCondition(c35089369.condition)
	e1:SetTarget(c35089369.target)
	e1:SetOperation(c35089369.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c35089369.sccon)
	e2:SetTarget(c35089369.sctg)
	e2:SetOperation(c35089369.scop)
	c:RegisterEffect(e2)
	-- ③：这张卡为同调素材的同调怪兽不受魔法卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c35089369.immcon)
	e3:SetOperation(c35089369.immop)
	c:RegisterEffect(e3)
end
-- 判定①效果的诱发条件：这张卡在自己场上因战斗或效果被破坏并送去墓地，且破坏前的控制者是发动者本人。
function c35089369.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 定义①效果可特殊召唤的怪兽条件：持有『龙星』字段、不是「风龙星-蒲牢」、且能够以表侧攻击表示特殊召唤。
function c35089369.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(35089369) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①效果发动时的目标确认：若自己场上存在空余怪兽区，且卡组中有符合条件的『龙星』怪兽，则允许发动。
function c35089369.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的『龙星』怪兽。
		and Duel.IsExistingMatchingCard(c35089369.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定本连锁的操作信息为“从卡组特殊召唤1只怪兽”，以配合后续处理与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若自己怪兽区有空位，则从卡组选出1只符合条件的『龙星』怪兽并以表侧攻击表示特殊召唤。
function c35089369.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用怪兽区，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，要求玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选取1张符合条件的『龙星』怪兽。
	local g=Duel.SelectMatchingCard(tp,c35089369.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
-- ②效果的发动条件：当前为对方回合，且处于主要阶段1、战斗阶段或主要阶段2。
function c35089369.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前是己方回合则不能发动（要求对方回合）。
	if Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前阶段，用于判断是否处于允许发动的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 定义②效果的同调素材筛选条件：对象需为持有『龙星』字段的怪兽。
function c35089369.mfilter(c)
	return c:IsSetCard(0x9e)
end
-- ②效果发动时的目标确认：检查自己场上存在『龙星』怪兽，且额外卡组中存在能用它们进行同调召唤的怪兽。
function c35089369.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己场上所有持有『龙星』字段的怪兽，作为同调召唤的素材候选。
		local mg=Duel.GetMatchingGroup(c35089369.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 确认额外卡组中是否存在可用这些素材进行同调召唤的同调怪兽。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设定连锁的操作信息为“从额外卡组特殊召唤1只怪兽”（即同调召唤），用于效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：以自己场上所有『龙星』怪兽作为素材组，从额外卡组选择1只可同调召唤的怪兽进行同调召唤。
function c35089369.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有『龙星』怪兽作为这次同调召唤的素材组。
	local mg=Duel.GetMatchingGroup(c35089369.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 取得额外卡组中所有能用该素材组进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤，将选择的额外怪兽用『龙星』素材组进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- ③效果的触发条件：这张卡作为同调素材被使用（REASON_SYNCHRO）时触发。
function c35089369.immcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 为作为这张卡同调召唤产物的同调怪兽注册一个“不受魔法卡效果影响”的永续效果。
function c35089369.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：这张卡为同调素材的同调怪兽不受魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35089369,1))  --"「风龙星-蒲牢」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c35089369.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
-- 判定被免疫的效果范围：仅免疫发动主体为魔法卡的效果（te:IsActiveType(TYPE_SPELL)）。
function c35089369.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
