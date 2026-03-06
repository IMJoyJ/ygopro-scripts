--GP－リオン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以战士族以外的自己墓地1只「黄金荣耀」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「黄金荣耀」怪兽不能从额外卡组特殊召唤。
-- ③：对方主要阶段才能发动。只用自己场上的「黄金荣耀」怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 初始化卡片效果，创建三个效果分别为①②③效果
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
	-- ②：这张卡召唤·特殊召唤的场合，以战士族以外的自己墓地1只「黄金荣耀」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「黄金荣耀」怪兽不能从额外卡组特殊召唤。
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
-- 判断当前玩家基本分是否小于对方基本分
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家基本分是否小于对方基本分
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 设置①效果的发动条件和目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的OperationInfo信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行①效果的处理流程
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若卡片在场则特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 定义过滤函数，筛选非战士族且为黄金荣耀的墓地怪兽
function s.filter(c,e,tp)
	return not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x192)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置②效果的目标选择和条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的OperationInfo信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行②效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽在场则以守备表示特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 创建并注册限制非黄金荣耀怪兽从额外卡组特殊召唤的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制效果的过滤函数
function s.splimit(e,c)
	return not c:IsSetCard(0x192) and c:IsLocation(LOCATION_EXTRA)
end
-- 设置③效果的发动条件
function s.scon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为对方主要阶段
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 设置③效果的目标和条件
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有黄金荣耀怪兽作为同调素材
	local g=Duel.GetSynchroMaterial(tp):Filter(Card.IsSetCard,nil,0x192)
	-- 判断是否满足同调召唤条件
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,g) end
	-- 设置效果处理时的OperationInfo信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行③效果的处理流程
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有黄金荣耀怪兽作为同调素材
	local g=Duel.GetSynchroMaterial(tp):Filter(Card.IsSetCard,nil,0x192)
	if #g==0 then return end
	-- 提示选择要同调召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要同调召唤的怪兽
	local sc=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil,g):GetFirst()
	-- 执行同调召唤手续
	if sc then Duel.SynchroSummon(tp,sc,nil,g) end
end
