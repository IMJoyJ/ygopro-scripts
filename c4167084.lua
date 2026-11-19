--黎明の堕天使ルシフェル
-- 效果：
-- 天使族·暗属性怪兽×3
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合才能发动。对方场上的卡全部破坏。
-- ②：只要这张卡在怪兽区域存在，自己场上的天使族怪兽不会成为对方的效果的对象。
-- ③：自己·对方的主要阶段支付1000基本分才能发动。从自己的手卡·墓地选1只天使族怪兽守备表示特殊召唤。
function c4167084.initial_effect(c)
	-- 记录这张卡的卡文上记载了「堕天使 路西菲尔」的卡名。
	aux.AddCodeList(c,25451652)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以3只暗属性·天使族怪兽作为融合素材。
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
	-- ①：「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合才能发动。
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
	-- 限制受保护对象为自己场上的天使族怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	-- 设置不会被对方的效果作为对象（仅己方效果可选中）。
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
-- 融合素材过滤函数：判断怪兽的融合属性是否为暗属性且种族为天使族。
function c4167084.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY)
end
-- ①效果的发动条件判定：检查这张卡是否为融合召唤且在融合素材检查中标记为使用了「堕天使 路西菲尔」。
function c4167084.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的目标处理函数：检查对方场上是否存在卡片，并申报将对方场上所有卡破坏的操作信息。
function c4167084.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有卡片组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：预计破坏对方场上的全部卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的效果处理函数：获取对方场上的全部卡片并以效果破坏。
function c4167084.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将对方场上的全部卡片以效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 融合素材检查函数：检测融合素材中是否包含融合卡名为「堕天使 路西菲尔」的卡，并把结果记录到①效果的Label中。
function c4167084.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionCode,1,nil,25451652) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ③效果的发动条件判定：检查当前是否处于主要阶段1或主要阶段2。
function c4167084.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前决斗阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ③效果的代价处理函数：检查并支付1000点基本分。
function c4167084.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价可行性检测：检查自己玩家是否能支付1000点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让自己玩家支付1000点基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：判断怪兽是否为天使族且能以表侧守备表示特殊召唤。
function c4167084.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果的目标处理函数：检查自己怪兽区是否有空位且手卡或墓地存在可守备特召的天使族怪兽，并申报特召操作信息。
function c4167084.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检测：检查自己怪兽区有空位且自己手卡或墓地存在至少1只可表侧守备表示特殊召唤的天使族怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c4167084.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己的手卡或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ③效果的效果处理函数：若自己怪兽区有空位，则从手卡或墓地选1只不受「王家长眠之谷」限制的天使族怪兽表侧守备表示特殊召唤。
function c4167084.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否没有可用空位，若没有则结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或墓地选择1只不受王家长眠之谷影响的符合条件的天使族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4167084.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的天使族怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
