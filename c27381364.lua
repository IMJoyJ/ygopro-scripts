--スプライト・エルフ
-- 效果：
-- 包含2星·2阶·连接2的怪兽在内的怪兽2只
-- 这张卡在连接召唤的回合不能作为连接素材。这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把这张卡所连接区的怪兽作为效果的对象。
-- ②：自己·对方的主要阶段，以自己墓地1只2星怪兽为对象才能发动（对方场上有怪兽存在的场合，也能作为代替以1只2阶或者连接2的怪兽为对象）。那只怪兽特殊召唤。
function c27381364.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,c27381364.lcheck)
	-- 这张卡在连接召唤的回合不能作为连接素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c27381364.lmlimit)
	c:RegisterEffect(e1)
	-- 对方不能把这张卡所连接区的怪兽作为效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c27381364.etlimit)
	-- 设置效果值为aux.tgoval函数，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 自己·对方的主要阶段，以自己墓地1只2星怪兽为对象才能发动（对方场上有怪兽存在的场合，也能作为代替以1只2阶或者连接2的怪兽为对象）。那只怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,27381364)
	e3:SetCondition(c27381364.spcon)
	e3:SetTarget(c27381364.sptg)
	e3:SetOperation(c27381364.spop)
	c:RegisterEffect(e3)
end
-- 连接素材检查函数，判断是否包含2星、2阶或连接2的怪兽
function c27381364.lcheck(g,lc)
	return g:IsExists(Card.IsLevel,1,nil,2) or g:IsExists(Card.IsRank,1,nil,2) or g:IsExists(Card.IsLink,1,nil,2)
end
-- 连接素材限制函数，判断当前卡是否在连接召唤的回合
function c27381364.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果对象限制函数，判断目标怪兽是否在连接区
function c27381364.etlimit(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 特殊召唤发动条件函数，判断是否在主要阶段1或主要阶段2
function c27381364.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 特殊召唤目标过滤函数，判断墓地怪兽是否满足特殊召唤条件
function c27381364.spfilter(c,e,tp,check)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLevel(2) or (check and (c:IsRank(2) or c:IsLink(2))))
end
-- 特殊召唤目标选择函数，设置目标选择条件
function c27381364.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断对方场上是否有怪兽存在
	local check=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27381364.spfilter(chkc,e,tp,check) end
	-- 判断是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c27381364.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,check) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c27381364.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	-- 设置连锁操作信息，指定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理函数，执行特殊召唤操作
function c27381364.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否还有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
