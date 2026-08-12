--夢魔鏡の乙女－イケロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。从卡组把「梦魔镜的少女-伊刻罗斯」以外的1张「梦魔镜」卡加入手卡。
-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的梦魔-伊刻罗斯」特殊召唤。
function c49389190.initial_effect(c)
	-- 注册该卡牌与「梦魔镜」系列怪兽的关联，用于效果判定
	aux.AddCodeList(c,1050355,75888208)
	-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。从卡组把「梦魔镜的少女-伊刻罗斯」以外的1张「梦魔镜」卡加入手卡。
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
-- 判断此卡是否由「梦魔镜」怪兽的效果特殊召唤成功（即满足①效果发动条件）
function c49389190.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 过滤函数：筛选出「梦魔镜」系列且非自身、可加入手牌的卡片
function c49389190.thfilter(c)
	return c:IsSetCard(0x131) and not c:IsCode(49389190) and c:IsAbleToHand()
end
-- 设置连锁处理信息：准备从卡组检索一张「梦魔镜」卡加入手牌
function c49389190.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果发动条件：卡组中存在符合条件的「梦魔镜」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49389190.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将要处理的卡为1张从卡组加入手牌的「梦魔镜」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果的处理：选择并把符合条件的卡加入手牌，并向对手确认
function c49389190.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 根据过滤条件从卡组中选择一张卡
	local g=Duel.SelectMatchingCard(tp,c49389190.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手确认所选卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断②效果是否可以发动：当前阶段为己方主要阶段或战斗阶段，且场地区域存在「黯黑之梦魔镜」
function c49389190.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查场地是否存在「黯黑之梦魔镜」
		and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- 设置②效果的费用：解放自身作为发动代价
function c49389190.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身以效果原因进行解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选出「梦魔镜的梦魔-伊刻罗斯」且可特殊召唤的卡片
function c49389190.spfilter(c,e,tp)
	return c:IsCode(75888208) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理信息：准备从卡组特殊召唤一只「梦魔镜的梦魔-伊刻罗斯」
function c49389190.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果发动条件：己方怪兽区域有空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查是否满足②效果发动条件：卡组中存在符合条件的「梦魔镜的梦魔-伊刻罗斯」
		and Duel.IsExistingMatchingCard(c49389190.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：将要处理的卡为1只从卡组特殊召唤的「梦魔镜的梦魔-伊刻罗斯」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的处理：选择并把符合条件的卡特殊召唤到场上
function c49389190.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区域是否有空位，若无则不继续处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据过滤条件从卡组中选择一张卡
	local g=Duel.SelectMatchingCard(tp,c49389190.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
