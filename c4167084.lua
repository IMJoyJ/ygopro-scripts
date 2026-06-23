--黎明の堕天使ルシフェル
-- 效果：
-- 天使族·暗属性怪兽×3
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合才能发动。对方场上的卡全部破坏。
-- ②：只要这张卡在怪兽区域存在，自己场上的天使族怪兽不会成为对方的效果的对象。
-- ③：自己·对方的主要阶段支付1000基本分才能发动。从自己的手卡·墓地选1只天使族怪兽守备表示特殊召唤。
function c4167084.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个满足条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c4167084.ffilter,3,true)
	-- ①：「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合才能发动。对方场上的卡全部破坏。
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
	-- ①：「堕天使 路西菲尔」作为素材让这张卡融合召唤成功的场合才能发动。对方场上的卡全部破坏。
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
	-- 设置效果目标为天使族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	-- 设置效果值为判断是否为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：自己·对方的主要阶段支付1000基本分才能发动。从自己的手卡·墓地选1只天使族怪兽守备表示特殊召唤。
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
-- 过滤函数，返回满足暗属性且天使族的怪兽
function c4167084.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY)
end
-- 判断是否为融合召唤成功且标记为1
function c4167084.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索对方场上所有卡并设置为破坏效果的目标
function c4167084.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将目标卡破坏
function c4167084.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 执行破坏效果，将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 检查融合素材中是否包含堕天使 路西菲尔，若包含则设置标记为1
function c4167084.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionCode,1,nil,25451652) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断当前是否为主阶段1或主阶段2
function c4167084.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主阶段1或主阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 支付1000基本分作为发动费用
function c4167084.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为发动费用
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，返回满足天使族且可特殊召唤的怪兽
function c4167084.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标为手卡或墓地的天使族怪兽
function c4167084.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在满足条件的天使族怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c4167084.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作，将选中的天使族怪兽特殊召唤
function c4167084.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4167084.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
