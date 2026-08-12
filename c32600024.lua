--ドラゴンメイド・チェイム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「半龙女仆」魔法·陷阱卡加入手卡。
-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只7星以上的「半龙女仆」怪兽特殊召唤。
function c32600024.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「半龙女仆」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32600024,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,32600024)
	e1:SetTarget(c32600024.srtg)
	e1:SetOperation(c32600024.srop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只7星以上的「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32600024,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,32600025)
	e3:SetTarget(c32600024.sptg)
	e3:SetOperation(c32600024.spop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「半龙女仆」魔法·陷阱卡的过滤函数
function c32600024.srfilter(c)
	return c:IsSetCard(0x133) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并设置操作信息
function c32600024.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中是否存在满足条件的「半龙女仆」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32600024.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张「半龙女仆」魔法·陷阱卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于执行效果的处理逻辑
function c32600024.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「半龙女仆」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c32600024.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索满足条件的「半龙女仆」7星以上怪兽的过滤函数
function c32600024.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并设置操作信息
function c32600024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 判断是否满足发动条件：场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 判断是否满足发动条件：手卡或墓地中是否存在满足条件的「半龙女仆」7星以上怪兽
		and Duel.IsExistingMatchingCard(c32600024.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：将该卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：从手卡或墓地特殊召唤1只满足条件的「半龙女仆」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数，用于执行效果的处理逻辑
function c32600024.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足处理条件：该卡是否还在场上且成功送回手牌
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 判断是否满足处理条件：该卡在手牌中且场上存在可用怪兽区域
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或墓地中选择1只满足条件的「半龙女仆」7星以上怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32600024.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
