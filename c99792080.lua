--夢魔鏡の魔獣－パンタス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。这个回合，这张卡可以直接攻击。
-- ②：场地区域有「圣光之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的圣兽-方塔斯」特殊召唤。
function c99792080.initial_effect(c)
	-- 将卡名「圣光之梦魔镜」(74665651)和「梦魔镜的圣兽-方塔斯」(62393472)登记到这张卡的代码列表中，用于效果文本中记载卡名的关联判定。
	aux.AddCodeList(c,74665651,62393472)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。这个回合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99792080,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,99792080)
	e1:SetCondition(c99792080.dircon)
	e1:SetOperation(c99792080.dirop)
	c:RegisterEffect(e1)
	-- ②：场地区域有「圣光之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的圣兽-方塔斯」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99792080,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_END)
	e2:SetCountLimit(1,99792081)
	e2:SetCondition(c99792080.spcon)
	e2:SetCost(c99792080.spcost)
	e2:SetTarget(c99792080.sptg)
	e2:SetOperation(c99792080.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：确认这张卡是被特殊召唤成功的怪兽、且是由「梦魔镜」怪兽的效果特殊召唤，同时当前处于可进入或正在进行战斗阶段的时点。
function c99792080.dircon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这次特殊召唤的信息包含怪兽类型、满足被「梦魔镜」系列效果特殊召唤的标记，并且当前阶段满足aux.bpcon（可进入战斗阶段或正处于战斗阶段）。
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131) and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- ①效果处理：若这张卡仍存在于场上且与效果相关，就给它赋予本回合可以直接攻击的效果。
function c99792080.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件判定：当前处于自己/对方的主要阶段1、主要阶段2或战斗阶段，且场地区域有「圣光之梦魔镜」存在。
function c99792080.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于下面的阶段判断。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查场地区域是否存在卡号74665651的「圣光之梦魔镜」，不限控制者。
		and Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end
-- ②效果的发动代价：将这张卡解放作为cost。先检查这张卡是否可以解放，然后实际执行解放。
function c99792080.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 以『解放』作为发动代价将这张卡送去墓地（REASON_COST，不因效果抗性而无法解放）。
	Duel.Release(c,REASON_COST)
end
-- 定义可特殊召唤的卡筛选条件：必须是卡号为62393472的「梦魔镜的圣兽-方塔斯」，并且可以被正常特殊召唤。
function c99792080.spfilter(c,e,tp)
	return c:IsCode(62393472) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时检查：自己场上（这张卡解放后空出的位置）是否有可用怪兽区，且卡组中存在符合条件的「梦魔镜的圣兽-方塔斯」。
function c99792080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区格（计算这张卡离开后空出的空格）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否有至少1张满足spfilter的「梦魔镜的圣兽-方塔斯」。
		and Duel.IsExistingMatchingCard(c99792080.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次效果处理的信息登记为特殊召唤，预定从卡组特殊召唤1张卡，供其他卡片进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若自己怪兽区仍有空位，从卡组选择1只「梦魔镜的圣兽-方塔斯」并正面特殊召唤。
function c99792080.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认怪兽区有空位，如果没空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择提示消息，提示需要选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足spfilter的「梦魔镜的圣兽-方塔斯」。
	local g=Duel.SelectMatchingCard(tp,c99792080.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以正面表示特殊召唤到己方场上，进行通常的特殊召唤合法性检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
