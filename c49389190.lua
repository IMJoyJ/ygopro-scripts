--夢魔鏡の乙女－イケロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。从卡组把「梦魔镜的少女-伊刻罗斯」以外的1张「梦魔镜」卡加入手卡。
-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的梦魔-伊刻罗斯」特殊召唤。
function c49389190.initial_effect(c)
	-- 将「黯黑之梦魔镜」（卡号1050355）和「梦魔镜的梦魔-伊刻罗斯」（卡号75888208）登记为本卡记载的卡片名，用于后续相关字段/效果判定。
	aux.AddCodeList(c,1050355,75888208)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。从卡组把「梦魔镜的少女-伊刻罗斯」以外的1张「梦魔镜」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49389190,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,49389190)
	e1:SetCondition(c49389190.thcon)
	e1:SetTarget(c49389190.thtg)
	e1:SetOperation(c49389190.thop)
	c:RegisterEffect(e1)
	-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的梦魔-伊刻罗斯」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49389190,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,49389191)
	e2:SetCondition(c49389190.spcon)
	e2:SetCost(c49389190.spcost)
	e2:SetTarget(c49389190.sptg)
	e2:SetOperation(c49389190.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定：确认这张卡是以怪兽效果且通过「梦魔镜」怪兽的效果进行的特殊召唤成功，以此判断是否符合『用「梦魔镜」怪兽的效果特殊召唤成功的场合』。
function c49389190.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 筛选满足①的从卡组加入手牌的卡：必须属于「梦魔镜」字段、不是本卡「梦魔镜的少女-伊刻罗斯」自身、并且能加入手牌。
function c49389190.thfilter(c)
	return c:IsSetCard(0x131) and not c:IsCode(49389190) and c:IsAbleToHand()
end
-- 效果①的发动时处理：在 chk==0 时检查卡组是否存在合法检索目标，并登记本次操作信息（将1张卡从卡组加入手牌）。
function c49389190.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中至少存在1张符合条件的「梦魔镜」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c49389190.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果会把1张来自卡组的卡加入手牌，供关于回手牌/检索的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组选择1张符合条件的「梦魔镜」卡加入手牌，并向对方展示。
function c49389190.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选出1张满足thfilter条件的「梦魔镜」卡。
	local g=Duel.SelectMatchingCard(tp,c49389190.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡加入其持有者的手牌（因为效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件判定：当前阶段为主要阶段1、战斗阶段（从开始到结束）或主要阶段2，并且场地区域存在「黯黑之梦魔镜」。
function c49389190.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否在主要阶段或战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查双方场地区域是否有卡名「黯黑之梦魔镜」（卡号1050355）存在。
		and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- 效果②的发动代价判定：确认本卡可以被解放；随后执行解放作为代价。
function c49389190.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为效果②的发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤对象的筛选条件：卡号必须是75888208「梦魔镜的梦魔-伊刻罗斯」，且该卡能够被玩家tp以效果e特殊召唤（检查召唤条件和苏生限制）。
function c49389190.spfilter(c,e,tp)
	return c:IsCode(75888208) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时处理：确认自己场上（解放本卡后）有可用怪兽区，且卡组中存在特殊召唤对象；并登记本次特殊召唤操作信息。
function c49389190.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：解放本卡后，自己场上仍有可用的怪兽区可放置特殊召唤怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 发动合法性检查：卡组中存在1只满足spfilter条件的「梦魔镜的梦魔-伊刻罗斯」。
		and Duel.IsExistingMatchingCard(c49389190.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果会将1只来自卡组的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1只「梦魔镜的梦魔-伊刻罗斯」以表侧表示特殊召唤到自己场上。
function c49389190.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认自己场上仍有可用的怪兽区，否则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选出1只满足spfilter条件的「梦魔镜的梦魔-伊刻罗斯」。
	local g=Duel.SelectMatchingCard(tp,c49389190.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
