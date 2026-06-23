--夢魔鏡の白騎士－ルペウス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。这个回合，这张卡不会被战斗·效果破坏。
-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的黑骑士-卢甫斯」特殊召唤。
function c1872843.initial_effect(c)
	-- 注册此卡为记载了「梦魔镜」和「梦魔镜的黑骑士-卢甫斯」卡名的卡片
	aux.AddCodeList(c,1050355,38267552)
	-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。这个回合，这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1872843,0))
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1872843)
	e1:SetCondition(c1872843.indcon)
	e1:SetOperation(c1872843.indop)
	c:RegisterEffect(e1)
	-- ②：场地区域有「黯黑之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的黑骑士-卢甫斯」特殊召唤。
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
-- 判断此卡是否由「梦魔镜」怪兽的效果特殊召唤成功
function c1872843.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 使此卡在本回合内不会被战斗或效果破坏
function c1872843.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使此卡在本回合内不会被战斗破坏
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
-- 判断当前是否处于主要阶段或战斗阶段且场地区域存在「黯黑之梦魔镜」
function c1872843.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查场地区域是否存在「黯黑之梦魔镜」
		and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- 支付此卡作为解放的费用
function c1872843.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从场上解放作为发动费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义用于筛选「梦魔镜的黑骑士-卢甫斯」的过滤函数
function c1872843.spfilter(c,e,tp)
	return c:IsCode(38267552) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的处理信息，确定将要特殊召唤1只「梦魔镜的黑骑士-卢甫斯」
function c1872843.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查玩家卡组中是否存在满足条件的「梦魔镜的黑骑士-卢甫斯」
		and Duel.IsExistingMatchingCard(c1872843.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作，从卡组选择1只「梦魔镜的黑骑士-卢甫斯」特殊召唤
function c1872843.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「梦魔镜的黑骑士-卢甫斯」
	local g=Duel.SelectMatchingCard(tp,c1872843.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
