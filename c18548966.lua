--H・C モーニング・スター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有战士族怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「英豪」魔法·陷阱卡加入手卡。
-- ③：这张卡在墓地存在，自己基本分是500以下的场合才能发动。这张卡效果无效特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，创建三个效果分别为①②③效果
function c18548966.initial_effect(c)
	-- ①：自己场上有战士族怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18548966)
	e1:SetCondition(c18548966.spcon)
	e1:SetTarget(c18548966.sptg)
	e1:SetOperation(c18548966.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「英豪」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,18548966+o)
	e2:SetTarget(c18548966.thtg)
	e2:SetOperation(c18548966.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在，自己基本分是500以下的场合才能发动。这张卡效果无效特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,18548966+o*2)
	e4:SetCondition(c18548966.rvcon)
	e4:SetTarget(c18548966.rvtg)
	e4:SetOperation(c18548966.rvop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在正面表示的战士族怪兽
function c18548966.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 判断自己场上是否存在至少2只正面表示的战士族怪兽
function c18548966.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少2只正面表示的战士族怪兽
	return Duel.IsExistingMatchingCard(c18548966.filter,tp,LOCATION_MZONE,0,2,nil)
end
-- 设置①效果的发动条件判断
function c18548966.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在至少1个空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置①效果发动时的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理函数
function c18548966.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡从手卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于检索卡组中「英豪」魔法·陷阱卡
function c18548966.thfilter(c)
	return c:IsSetCard(0x6f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置②效果的发动条件判断
function c18548966.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组中是否存在至少1张「英豪」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18548966.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置②效果发动时的操作信息为从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的发动处理函数
function c18548966.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「英豪」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c18548966.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件判断
function c18548966.rvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己基本分是否小于等于500
	return Duel.GetLP(tp)<=500
end
-- 设置③效果的发动条件判断
function c18548966.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在至少1个空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置③效果发动时的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的发动处理函数
function c18548966.rvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否能被特殊召唤且是否在场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 使该卡获得无效化效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 使该卡获得无效化效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
