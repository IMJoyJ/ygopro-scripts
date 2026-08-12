--見えざる手イブエル
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。这张卡回到卡组。那之后，从卡组把「不可见之手 诱天手」以外的1只「不可见之手」怪兽守备表示特殊召唤。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：这张卡被送去墓地的场合，以「不可见之手 诱天手」以外的自己墓地1只「不可见之手」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手卡起动特召效果、②战斗破坏抗性效果、③送墓诱发特召效果。
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。这张卡回到卡组。那之后，从卡组把「不可见之手 诱天手」以外的1只「不可见之手」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以「不可见之手 诱天手」以外的自己墓地1只「不可见之手」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- ①效果的Cost：检查手卡的这张卡是否未给对方观看（未公开状态）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果的过滤条件：卡组中除「不可见之手 诱天手」以外的「不可见之手」怪兽，且能以表侧守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1d3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备：检查怪兽区域是否有空位、卡组中是否存在符合特殊召唤条件的怪兽，以及自身是否能回到卡组。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的「不可见之手」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and c:IsAbleToDeck() end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：将自身送回卡组，若成功则从卡组将1只符合条件的「不可见之手」怪兽守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与连锁相关，并将其送回卡组洗牌。
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK) then
		-- 检查自己场上是否有可用的怪兽区域空位，若无则结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只符合条件的「不可见之手」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的特殊召唤不与回卡组视为同时处理（防止错时点）。
			Duel.BreakEffect()
			-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- ②效果的适用对象过滤：自身或者自身的战斗对象。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ③效果的过滤条件：墓地中除「不可见之手 诱天手」以外的「不可见之手」怪兽，且能特殊召唤。
function s.spfilter2(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1d3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动准备：检查怪兽区域是否有空位、墓地中是否存在符合特殊召唤条件的怪兽，并选择1只作为效果对象。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在至少1只符合条件的「不可见之手」怪兽。
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地中1只符合条件的「不可见之手」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息：将选择的目标怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果的处理：将作为效果对象的墓地怪兽特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与连锁相关，且不受「王家之谷-Necrovalley」的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
