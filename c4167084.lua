--黎明の堕天使ルシフェル
-- 效果：
-- 天使族·暗属性怪兽×3
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合才能发动。对方场上的卡全部破坏。
-- ②：只要这张卡在怪兽区域存在，自己场上的天使族怪兽不会成为对方的效果的对象。
-- ③：自己·对方的主要阶段支付1000基本分才能发动。从自己的手卡·墓地选1只天使族怪兽守备表示特殊召唤。
function c4167084.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以3只暗属性·天使族怪兽作为素材进行融合召唤。
	aux.AddFusionProcFunRep(c,c4167084.ffilter,3,true)
	-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。①：「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合才能发动。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4167084,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,4167084)
	e1:SetCondition(c4167084.descon)
	e1:SetTarget(c4167084.destg)
	e1:SetOperation(c4167084.desop)
	c:RegisterEffect(e1)
	-- 「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c4167084.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己场上的天使族怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 将该效果的保护对象限定为天使族怪兽，即自己场上的天使族怪兽不会成为对方的效果的对象。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	-- 设置该效果的值，用于判定‘对方的效果’，从而实现天使族怪兽不会成为对方效果的对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。③：自己·对方的主要阶段支付1000基本分才能发动。从自己的手卡·墓地选1只天使族怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4167084,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,4167084)
	e4:SetCondition(c4167084.spcon)
	e4:SetCost(c4167084.spcost)
	e4:SetTarget(c4167084.sptg)
	e4:SetOperation(c4167084.spop)
	c:RegisterEffect(e4)
end
-- 定义融合素材条件：怪兽必须为暗属性且天使族。
function c4167084.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY)
end
-- ①效果的发动条件：此卡以融合召唤方式特殊召唤成功，且其融合素材中包含「堕天使 路西菲尔」。
function c4167084.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的发动时处理：获取对方场上的全部卡，若存在则设置将这些卡全部破坏的操作信息。
function c4167084.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上（怪兽区域+魔法陷阱区域）的所有卡，作为将被破坏的对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 登记破坏操作信息：将对方场上全部卡设置为破坏对象，数量为当前卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理时：再次获取对方场上的全部卡，若存在则将其全部破坏。
function c4167084.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的所有卡，作为实际破坏的目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 以效果原因破坏这些卡片，令其送去墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 素材确认函数：检查融合素材中是否有「堕天使 路西菲尔」（卡号25451652），并据此设置e1标签，供①效果的发动条件使用。
function c4167084.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionCode,1,nil,25451652) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ③效果的发动条件：只能在主要阶段1或主要阶段2（即自己或对方的主要阶段）发动。
function c4167084.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ③效果的代价：需要支付1000基本分。
function c4167084.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己是否能支付1000基本分，若不能则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- ③效果特殊召唤对象的过滤条件：必须是天使族怪兽，且可以表侧守备表示特殊召唤。
function c4167084.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果发动时处理：确认自己场上有可用怪兽区，且手卡·墓地存在可特殊召唤的天使族怪兽，并登记特殊召唤操作信息。
function c4167084.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否有可用怪兽区，以及手卡·墓地是否有满足条件的天使族怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c4167084.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记特殊召唤操作信息：从自己的手卡·墓地特殊召唤1只天使族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ③效果处理时：从手卡·墓地选择1只天使族怪兽，以表侧守备表示特殊召唤。
function c4167084.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己场上是否有可用怪兽区，若无则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只满足条件且不受王家长眠之谷影响的天使族怪兽，作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4167084.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的天使族怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
