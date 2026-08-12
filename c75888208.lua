--夢魔鏡の夢魔－イケロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。从手卡把「梦魔镜的梦魔-伊刻罗斯」以外的1只「梦魔镜」怪兽特殊召唤。
-- ②：场地区域有「圣光之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的少女-伊刻罗斯」特殊召唤。
function c75888208.initial_effect(c)
	-- 注册卡片关联密码，记录本卡记载了「圣光之梦魔镜」与「梦魔镜的少女-伊刻罗斯」
	aux.AddCodeList(c,74665651,49389190)
	-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合才能发动。从手卡把「梦魔镜的梦魔-伊刻罗斯」以外的1只「梦魔镜」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75888208,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,75888208)
	e1:SetCondition(c75888208.spcon1)
	e1:SetTarget(c75888208.sptg1)
	e1:SetOperation(c75888208.spop1)
	c:RegisterEffect(e1)
	-- ②：场地区域有「圣光之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的少女-伊刻罗斯」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75888208,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,75888209)
	e2:SetCondition(c75888208.spcon2)
	e2:SetCost(c75888208.spcost2)
	e2:SetTarget(c75888208.sptg2)
	e2:SetOperation(c75888208.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的触发条件：此卡是由怪兽（「梦魔镜」怪兽）的效果特殊召唤成功
function c75888208.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 效果①的过滤条件：手牌中除「梦魔镜的梦魔-伊刻罗斯」以外的「梦魔镜」怪兽，且能特殊召唤
function c75888208.spfilter1(c,e,tp)
	return c:IsSetCard(0x131) and not c:IsCode(75888208) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及手牌中是否存在可特召的怪兽）
function c75888208.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测手牌中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c75888208.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的执行：从手牌选择1只满足条件的「梦魔镜」怪兽特殊召唤
function c75888208.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c75888208.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的触发条件：当前处于主要阶段或战斗阶段，且场地区域存在「圣光之梦魔镜」
function c75888208.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检测场地区域是否存在「圣光之梦魔镜」
		and Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end
-- 效果②的发动代价：将此卡解放
function c75888208.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的过滤条件：卡组中的「梦魔镜的少女-伊刻罗斯」，且能特殊召唤
function c75888208.spfilter2(c,e,tp)
	return c:IsCode(49389190) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测（检查此卡解放后怪兽区域空位及卡组中是否存在可特召的怪兽）
function c75888208.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测此卡解放后自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检测卡组中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c75888208.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的执行：从卡组选择1只「梦魔镜的少女-伊刻罗斯」特殊召唤
function c75888208.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c75888208.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
