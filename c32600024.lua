--ドラゴンメイド・チェイム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「半龙女仆」魔法·陷阱卡加入手卡。
-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只7星以上的「半龙女仆」怪兽特殊召唤。
function c32600024.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「半龙女仆」魔法·陷阱卡加入手卡。
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
-- 定义①效果检索的过滤条件：卡组中满足「半龙女仆」字段、魔法·陷阱卡类型、且能被加入手卡的卡。
function c32600024.srfilter(c)
	return c:IsSetCard(0x133) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动条件判定与操作信息设置：确认卡组存在可检索的「半龙女仆」魔法·陷阱卡，并注册将1张卡加入手卡的操作信息。
function c32600024.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1张满足检索条件的「半龙女仆」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c32600024.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：此效果将把1张卡从卡组加入持有者手卡，便于其他卡/效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的解决处理：从卡组选择1张符合条件的「半龙女仆」魔法·陷阱卡加入手卡，并向对方展示。
function c32600024.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家弹出选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 在当前处理的连锁中，从卡组精确选择1张满足检索条件的「半龙女仆」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c32600024.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果特殊召唤的过滤条件：卡名属于「半龙女仆」字段、等级7以上、且能被效果特殊召唤的怪兽。
function c32600024.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：确认本卡可以回手、自己场上有空余怪兽区、手牌/墓地存在满足条件的7星以上「半龙女仆」怪兽。
function c32600024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 确认本卡回手后自己场上仍有可用的怪兽区，用于后续特殊召唤。
		and Duel.GetMZoneCount(tp,c)>0
		-- 确认手牌·墓地存在至少1只满足②特殊召唤条件的7星以上「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(c32600024.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本卡（发动效果的这张卡）将被加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：将从手牌·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的解决处理：将本卡返回手牌，然后从手牌/墓地选择1只7星以上「半龙女仆」怪兽特殊召唤。
function c32600024.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与②效果保持关联，且成功将其返回手牌（返回值非0表示操作成功）。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认本卡已回到手卡，且自己场上存在可用的怪兽区。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌·墓地选择1只满足特殊召唤条件、且不受“王家长眠之谷”影响的7星以上「半龙女仆」怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32600024.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
