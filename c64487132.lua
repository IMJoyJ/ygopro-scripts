--ガジェット・ゲーマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1只机械族·1星怪兽加入手卡。
-- ②：把这张卡解放才能发动。从手卡把1只「变形斗士」怪兽特殊召唤。那之后，可以从手卡·卡组把1只「工具挂车」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只机械族·1星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从手卡把1只「变形斗士」怪兽特殊召唤。那之后，可以从手卡·卡组把1只「工具挂车」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中等级1的机械族且能加入手牌的怪兽
function s.thfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果①（检索）的发动准备与合法性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的机械族·1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索）的效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的机械族·1星怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②（特殊召唤）的发动代价处理
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否可以解放，且解放后是否有可用的怪兽区域
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 解放自身作为发动代价
	Duel.Release(c,REASON_COST)
end
-- 过滤手牌中可以特殊召唤的「变形斗士」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（特殊召唤）的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以特殊召唤的「变形斗士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤手牌或卡组中可以特殊召唤的「工具挂车」
function s.filter2(c,e,tp)
	return c:IsCode(28002611) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（特殊召唤）的效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无空位则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只「变形斗士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 获取手牌和卡组中所有可以特殊召唤的「工具挂车」
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 将选择的「变形斗士」怪兽以表侧表示特殊召唤，并检查是否特殊召唤成功
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查是否存在可特殊召唤的「工具挂车」，并询问玩家是否选择特殊召唤
		and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤「工具挂车」？"
		-- 中断当前效果处理，使后续的特殊召唤不与前面的特殊召唤同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的「工具挂车」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g2:Select(tp,1,1,nil)
		-- 将选择的「工具挂车」以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
