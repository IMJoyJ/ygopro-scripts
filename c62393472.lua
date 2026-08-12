--夢魔鏡の聖獣－パンタス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合，以「梦魔镜的圣兽-方塔斯」以外的自己墓地1只8星以下的「梦魔镜」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的魔兽-方塔斯」特殊召唤。
function c62393472.initial_effect(c)
	-- 注册卡片脚本中关联的卡片密码（「黯黑之梦魔镜」与「梦魔镜的魔兽-方塔斯」）。
	aux.AddCodeList(c,1050355,99792080)
	-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合，以「梦魔镜的圣兽-方塔斯」以外的自己墓地1只8星以下的「梦魔镜」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62393472,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,62393472)
	e1:SetCondition(c62393472.spcon1)
	e1:SetTarget(c62393472.sptg1)
	e1:SetOperation(c62393472.spop1)
	c:RegisterEffect(e1)
	-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的魔兽-方塔斯」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62393472,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_END)
	e2:SetCountLimit(1,62393473)
	e2:SetCondition(c62393472.spcon2)
	e2:SetCost(c62393472.spcost2)
	e2:SetTarget(c62393472.sptg2)
	e2:SetOperation(c62393472.spop2)
	c:RegisterEffect(e2)
end
-- 判定此卡是否由「梦魔镜」怪兽的效果特殊召唤成功。
function c62393472.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 过滤自己墓地中「梦魔镜的圣兽-方塔斯」以外的、8星以下且可以守备表示特殊召唤的「梦魔镜」怪兽。
function c62393472.spfilter1(c,e,tp)
	return c:IsSetCard(0x131) and c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(62393472)
end
-- 效果①的发动准备与目标选择。
function c62393472.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62393472.spfilter1(chkc,e,tp) end
	-- 判定自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足条件的「梦魔镜」怪兽。
		and Duel.IsExistingTarget(c62393472.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「梦魔镜」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c62393472.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理（将作为对象的怪兽守备表示特殊召唤）。
function c62393472.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判定当前是否为双方的主要阶段或战斗阶段，且场地区域是否存在「黯黑之梦魔镜」。
function c62393472.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 判定场地区域是否存在「黯黑之梦魔镜」。
		and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- 效果②的发动代价判定与执行。
function c62393472.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(c,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「梦魔镜的魔兽-方塔斯」。
function c62393472.spfilter2(c,e,tp)
	return c:IsCode(99792080) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备。
function c62393472.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定此卡解放后，自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判定自己卡组中是否存在可以特殊召唤的「梦魔镜的魔兽-方塔斯」。
		and Duel.IsExistingMatchingCard(c62393472.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理（从卡组将1只「梦魔镜的魔兽-方塔斯」特殊召唤）。
function c62393472.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「梦魔镜的魔兽-方塔斯」。
	local g=Duel.SelectMatchingCard(tp,c62393472.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
