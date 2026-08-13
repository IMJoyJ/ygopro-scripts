--ダーク・エレメント
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有「门之守护神」怪兽存在的场合，把基本分支付一半才能发动。从手卡·卡组·额外卡组把1只11星以上的「门之守护神」怪兽无视召唤条件特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
local s,id,o=GetID()
-- 注册这张卡的两个效果：①为魔法卡发动效果，满足条件时从手卡·卡组·额外卡组特殊召唤1只11星以上「门之守护神」怪兽；②为墓地发动的起动效果，通过除外自身检索「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」之一。
function s.initial_effect(c)
	-- 将「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的卡号登记到卡名列表中，标明这张卡记载了这些卡名。
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- ①：自己墓地有「门之守护神」怪兽存在的场合，把基本分支付一半才能发动。从手卡·卡组·额外卡组把1只11星以上的「门之守护神」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	-- 设置代价：把墓地中的这张卡除外（作为发动②的代价）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①的发动条件：自己墓地存在1只以上的「门之守护神」怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在1只字段为0x1052（「门之守护神」）的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x1052)
end
-- ①的发动代价：支付基本分的一半。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP的一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义可特殊召唤的怪兽的筛选条件：必须是11星以上的「门之守护神」怪兽，且能够被无视召唤条件特殊召唤，并且我方有可用的怪兽区域（额外卡组的怪兽还需额外怪兽区域）。
function s.filter(c,e,tp)
	-- 筛选条件：是0x1052「门之守护神」字段、等级11以上、可无视召唤条件特殊召唤，且场上/额外区有空位。
	return c:IsSetCard(0x1052) and c:IsLevelAbove(11) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①的发动目标：确认存在符合条件的可特殊召唤怪兽，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为合法性检查，则判断是否存在1只符合条件的「门之守护神」怪兽可从手卡·卡组·额外卡组特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：该效果预定从手卡·卡组·额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND)
end
-- 处理①效果：选择1只符合条件的「门之守护神」怪兽，无视召唤条件以表侧表示特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区域没有空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组·额外卡组中选择1只符合条件的「门之守护神」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 定义②检索卡的筛选条件：卡名是「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」之一，且可以加入手卡。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877) and c:IsAbleToHand()
end
-- ②的发动目标：确认存在符合条件的检索对象，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为合法性检查，则判断卡组·除外区是否存在至少1只符合条件的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：该效果预定从卡组·除外区将1只怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 处理②效果：选择1只符合条件的怪兽加入手卡，并展示给对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组·除外区选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
