--夢魔鏡の白騎士－ルペウス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。这个回合，这张卡不会被战斗·效果破坏。
-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的黑骑士-卢甫斯」特殊召唤。
function c1872843.initial_effect(c)
	-- 在卡片上登记1050355（「黯黑之梦魔镜」）和38267552（「梦魔镜的黑骑士-卢甫斯」）的卡号，用于效果叙述中涉及这些关联卡名/卡号的判定与检索。
	aux.AddCodeList(c,1050355,38267552)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。这个回合，这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1872843,0))
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1872843)
	e1:SetCondition(c1872843.indcon)
	e1:SetOperation(c1872843.indop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的黑骑士-卢甫斯」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1872843,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1872844)
	e2:SetCondition(c1872843.spcon)
	e2:SetCost(c1872843.spcost)
	e2:SetTarget(c1872843.sptg)
	e2:SetOperation(c1872843.spop)
	c:RegisterEffect(e2)
end
-- ①的发动条件判定：通过本次特殊召唤信息，确认召唤来源是怪兽，且该来源属于「梦魔镜」字段（setcode 0x131），即满足“用「梦魔镜」怪兽的效果特殊召唤成功”。
function c1872843.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- ①的效果处理：若这张卡仍与该效果关联，则给这张卡附加不会被战斗破坏和不会被效果破坏的持续效果，持续到本回合结束阶段，并随卡片离场等标准情况重置。
function c1872843.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
	end
end
-- ②的发动条件：当前阶段为主要阶段1、战斗阶段（从开始到结束）或主要阶段2，且场地区域有「黯黑之梦魔镜」存在。
function c1872843.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前阶段，用于判断是否处于可以发动②的主要阶段或战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 判定当前场地区域是否有「黯黑之梦魔镜」（卡号1050355）适用，且不限制是哪一方的场地。
		and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- ②的发动代价判定与执行：chk==0时确认这张卡可以解放；正式发动时解放这张卡作为cost。
function c1872843.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡解放，解放原因是cost，因此不受“不会被效果解放”等效果抗性影响。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤对象的过滤条件：卡号为38267552（「梦魔镜的黑骑士-卢甫斯」），且能够被当前效果特殊召唤。
function c1872843.spfilter(c,e,tp)
	return c:IsCode(38267552) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动合法性检查：解放这张卡后自己场上仍有空余怪兽区，且卡组中存在至少1只符合条件的黑骑士，满足才可发动。
function c1872843.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放这张卡后自己场上是否还有可用的空余怪兽区。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在至少1张满足spfilter（黑骑士且可特殊召唤）的卡。
		and Duel.IsExistingMatchingCard(c1872843.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记当前连锁的特殊召唤操作信息：从卡组特殊召唤1只怪兽，因效果处理时才确定具体对象，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：先确认仍有空余怪兽区，然后提示玩家选择并从卡组选1只「梦魔镜的黑骑士-卢甫斯」以表侧表示特殊召唤。
function c1872843.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有可用怪兽区；若没有则立即终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，用于后续从卡组选卡时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中选取1张满足spfilter的卡（黑骑士且可特殊召唤）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c1872843.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「梦魔镜的黑骑士-卢甫斯」以表侧表示特殊召唤到自己场上，按通常效果特殊召唤处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
