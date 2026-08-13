--GP－リオン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以战士族以外的自己墓地1只「黄金荣耀」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「黄金荣耀」怪兽不能从额外卡组特殊召唤。
-- ③：对方主要阶段才能发动。只用自己场上的「黄金荣耀」怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手卡起动特殊召唤效果、②召唤/特殊召唤成功时墓地特殊召唤并附加自肃效果、③对方主要阶段进行同调召唤的效果，并分别设置1回合1次的使用次数限制。
function s.initial_effect(c)
	-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合，以战士族以外的自己墓地1只「黄金荣耀」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：对方主要阶段才能发动。只用自己场上的「黄金荣耀」怪兽为素材进行同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCondition(s.scon)
	e4:SetTarget(s.stg)
	e4:SetOperation(s.sop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件判定：比较双方基本分，仅当己方LP低于对方时允许发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回己方LP是否小于对方LP的布尔值，作为①效果的条件。
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- ①效果发动时检查：自己主要怪兽区有空位，且此卡可以被特殊召唤，满足条件才可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否存在可用的空格，用于判定能否从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，声明本次效果将特殊召唤这张卡，供相关卡牌交互检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则将其从手卡以表侧攻击表示特殊召唤到自己场上。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认卡片仍与效果关联后，以表侧攻击表示形式特殊召唤此卡，不检查召唤条件与苏生限制。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 定义②效果可选择墓地的怪兽条件：不是战士族、属于「黄金荣耀」字段、且可以表侧守备表示特殊召唤。
function s.filter(c,e,tp)
	return not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x192)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的取对象判定：若检查对象则验证目标是否在墓地且由己方控制并满足条件；若发动检查则确认场上有空位且墓地存在满足条件的目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空位，确保可以特殊召唤墓地对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足s.filter条件的「黄金荣耀」怪兽，可作为取对象效果的目标。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示，提示其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「黄金荣耀」怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，声明将特殊召唤所选择的墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽表侧守备表示特殊召唤；若成功，给己方附加直到回合结束不能从额外卡组特殊召唤非「黄金荣耀」怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 这个效果的发动后，直到回合结束时自己不是「黄金荣耀」怪兽不能从额外卡组特殊召唤。③：对方主要阶段才能发动。只用自己场上的「黄金荣耀」怪兽为素材进行同调召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给己方玩家，使其在回合结束前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃判定条件：不是「黄金荣耀」字段且位于额外卡组的怪兽不能进行特殊召唤。
function s.splimit(e,c)
	return not c:IsSetCard(0x192) and c:IsLocation(LOCATION_EXTRA)
end
-- ③效果的发动条件：当前是对方回合，且处于主要阶段1或主要阶段2。
function s.scon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否满足对方主要阶段的条件，作为③效果的发动判定。
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ③效果发动时检查：获取自己场上「黄金荣耀」同调素材，并确认额外卡组存在能用这些素材同调召唤的怪兽，满足则通过并登记特殊召唤信息。
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的同调素材候选，并筛选出字段为「黄金荣耀」的怪兽。
	local g=Duel.GetSynchroMaterial(tp):Filter(Card.IsSetCard,nil,0x192)
	-- 检查是否存在至少1只「黄金荣耀」素材，且额外卡组中是否存在可用这些素材进行同调召唤的怪兽。
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,g) end
	-- 设置效果处理信息，声明本次将从额外卡组特殊召唤1只同调怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果处理：重新获取场上「黄金荣耀」素材，选择额外卡组中可同调召唤的怪兽，并使用这些素材进行同调召唤。
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取并筛选自己场上的「黄金荣耀」怪兽，作为同调召唤的素材。
	local g=Duel.GetSynchroMaterial(tp):Filter(Card.IsSetCard,nil,0x192)
	if #g==0 then return end
	-- 向玩家发送选择提示，提示其选择要特殊召唤的同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只当前素材可同调召唤的怪兽，并取出该卡。
	local sc=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil,g):GetFirst()
	-- 若成功选择同调怪兽，则以筛选出的「黄金荣耀」怪兽群为素材进行同调召唤。
	if sc then Duel.SynchroSummon(tp,sc,nil,g) end
end
