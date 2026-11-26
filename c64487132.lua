--ガジェット・ゲーマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1只机械族·1星怪兽加入手卡。
-- ②：把这张卡解放才能发动。从手卡把1只「变形斗士」怪兽特殊召唤。那之后，可以从手卡·卡组把1只「工具挂车」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①召唤成功时检索1只机械族·1星怪兽的诱发效果，以及②解放自身特召手卡「变形斗士」并追召「工具挂车」的起动效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤成功时才能发动。从卡组把1只机械族·1星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把这张卡解放才能发动。从手卡把1只「变形斗士」怪兽特殊召唤。那之后，可以从手卡·卡组把1只「工具挂车」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤等级1、机械族且可加入手卡的怪兽
function s.thfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 发动前确认卡组存在机械族·1星怪兽并登记检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在至少1只满足条件的机械族·1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记从己方卡组将1只怪兽加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从己方卡组选择1只机械族·1星怪兽加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方发送从卡组选择要加入手卡的怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从卡组选择1只机械族·1星怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果加入己方手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 支付②效果的发动代价：确认此卡可被解放且离场后己方怪兽区有空位，并将此卡作为代价解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动前确认此卡自身可解放，且解放后己方怪兽区至少有1个可用空位
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 将此卡自身作为发动代价解放
	Duel.Release(c,REASON_COST)
end
-- 过滤手卡中可特殊召唤的「变形斗士」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动前确认手卡存在可特召的「变形斗士」怪兽并登记特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手卡是否存在至少1只可特殊召唤的「变形斗士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记从己方手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤手卡或卡组中卡名为「工具挂车」且可特殊召唤的怪兽
function s.filter2(c,e,tp)
	return c:IsCode(28002611) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：从手卡选1只「变形斗士」怪兽特殊召唤，成功后若手卡·卡组有「工具挂车」且玩家选择是，则再特殊召唤1只「工具挂车」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查己方怪兽区是否有至少1个可用空位，不足则中止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向己方发送从手卡选择要特殊召唤的「变形斗士」怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方从手卡选择1只「变形斗士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 提前从己方卡组和手卡检索可特殊召唤的「工具挂车」卡片组
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 将选中的「变形斗士」怪兽以表侧表示特殊召唤到己方场上并判断是否成功
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 若存在可特召的「工具挂车」，询问己方玩家是否将其特殊召唤
		and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤「工具挂车」？"
		-- 插入效果处理间断，使「变形斗士」特召与后续「工具挂车」特召视为不同时处理
		Duel.BreakEffect()
		-- 向己方发送选择要特殊召唤的「工具挂车」的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g2:Select(tp,1,1,nil)
		-- 将选中的「工具挂车」以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
