--スプライト・エルフ
-- 效果：
-- 包含2星·2阶·连接2的怪兽在内的怪兽2只
-- 这张卡在连接召唤的回合不能作为连接素材。这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把这张卡所连接区的怪兽作为效果的对象。
-- ②：自己·对方的主要阶段，以自己墓地1只2星怪兽为对象才能发动（对方场上有怪兽存在的场合，也能作为代替以1只2阶或者连接2的怪兽为对象）。那只怪兽特殊召唤。
function c27381364.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用2只怪兽作为连接素材，且素材组中须包含等级2、阶级2或连接2的怪兽（具体由lcheck过滤）。
	aux.AddLinkProcedure(c,nil,2,2,c27381364.lcheck)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c27381364.lmlimit)
	c:RegisterEffect(e1)
	-- ①：对方不能把这张卡所连接区的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c27381364.etlimit)
	-- 设置该效果的Value为aux.tgoval，使“不能成为效果对象”的免疫效果只对对方玩家生效（己方仍可选择这些怪兽为对象）。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的主要阶段，以自己墓地1只2星怪兽为对象才能发动（对方场上有怪兽存在的场合，也能作为代替以1只2阶或者连接2的怪兽为对象）。那只怪兽特殊召唤。
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
-- 连接素材的额外过滤条件：素材组中存在任意1只等级2、阶级2或连接2的怪兽，满足“包含2星·2阶·连接2的怪兽”的要求。
function c27381364.lcheck(g,lc)
	return g:IsExists(Card.IsLevel,1,nil,2) or g:IsExists(Card.IsRank,1,nil,2) or g:IsExists(Card.IsLink,1,nil,2)
end
-- 判断这张卡是否处于连接召唤的回合（即本回合通过连接召唤特殊召唤上场），是则禁止将其用于连接素材。
function c27381364.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 判断目标怪兽是否位于这张卡的连接区域（即这张卡所连接区的怪兽），作为①效果的保护对象筛选。
function c27381364.etlimit(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- ②效果的发动条件：当前阶段是主要阶段1或主要阶段2，对应“自己·对方的主要阶段”。
function c27381364.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段1或主要阶段2（即自己或对方的主要阶段）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 特殊召唤对象的选择条件：怪兽可以被特殊召唤，且必须是等级2；若对方场上有怪兽（check为真），则也可以是阶级2或连接2的怪兽，对应括号内的代替对象。
function c27381364.spfilter(c,e,tp,check)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLevel(2) or (check and (c:IsRank(2) or c:IsLink(2))))
end
-- ②效果的取对象发动流程：先判断对方场上是否有怪兽以决定可选对象范围；在效果发动时检查场上是否有空位和合法对象；确认发动后从自己墓地选择1只符合条件的怪兽作为对象。
function c27381364.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测对方场上是否存在怪兽，用于决定能否选择阶级2或连接2的怪兽作为代替对象。
	local check=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27381364.spfilter(chkc,e,tp,check) end
	-- 效果发动合法性检查：自己主要怪兽区域必须存在空位，才能特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时墓地中必须存在至少1只满足spfilter条件的怪兽（可以是2星，或对方有怪兽时的2阶/连接2），且该怪兽能成为效果对象。
		and Duel.IsExistingTarget(c27381364.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,check) end
	-- 给当前玩家显示选择提示文字，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从自己墓地选择1只符合条件的怪兽，并设置为该连锁的对象。
	local g=Duel.SelectTarget(tp,c27381364.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	-- 登记操作信息，告知系统本次连锁将进行1只怪兽的特殊召唤，用于后续时点/连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：若场上仍有空位且对象仍与效果关联，则将对象怪兽特殊召唤到自己场上；否则不处理。
function c27381364.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区域有空位，若已无空位则直接终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时选择的对象怪兽（即自己墓地那1只目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上（nocheck=false表示仍检查召唤条件，nolimit=false表示仍检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
