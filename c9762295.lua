--光帰の旅－『セネト』
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：选自己的手卡·卡组·场上（表侧表示）·墓地的通常怪兽卡的以下数量，给双方确认。那之后，那个数量的以下效果适用。这个效果把手卡的卡确认的场合，再让自己可以抽1张。
-- ●2张：除效果怪兽外的1只8星以下的融合怪兽从额外卡组当作通常怪兽卡使用特殊召唤。
-- ●3张：卡组1只「塞尼特」怪兽或者自己墓地1只通常怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：选自己的手卡·卡组·场上（表侧表示）·墓地的通常怪兽卡的以下数量，给双方确认。那之后，那个数量的以下效果适用。这个效果把手卡的卡确认的场合，再让自己可以抽1张。●2张：除效果怪兽外的1只8星以下的融合怪兽从额外卡组当作通常怪兽卡使用特殊召唤。●3张：卡组1只「塞尼特」怪兽或者自己墓地1只通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·卡组·场上表侧·墓地的通常怪兽卡
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 过滤条件：额外卡组8星以下除效果怪兽外的融合怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(8)
		-- 确认怪兽可以特殊召唤且额外怪兽区或主要怪兽区有空格
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 过滤条件：卡组「塞尼特」怪兽或墓地通常怪兽
function s.spfilter2(c,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return c:IsSetCard(0x1eb)
	else
		return c:IsType(TYPE_NORMAL)
	end
end
-- 效果发动检查：确认是否有足够数量通常怪兽及对应可特殊召唤的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计可用于确认的通常怪兽卡总数
	local ct=Duel.GetMatchingGroupCount(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,nil)
	-- 检查是否满足2张分支条件：至少2张通常怪兽且额外卡组有对应融合怪兽
	local b1=ct>=2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	-- 检查是否满足3张分支条件：至少3张通常怪兽且怪兽区有空格
	local b2=ct>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在「塞尼特」怪兽或墓地是否存在通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
end
-- 效果处理：展示通常怪兽卡并适用对应数量的效果，若展示手卡则可抽1张卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有可用于确认的通常怪兽卡
	local sg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,nil)
	-- 判断是否满足适用2张分支效果的条件
	local b1=sg:GetCount()>=2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	-- 判断是否满足适用3张分支效果的条件
	local b2=sg:GetCount()>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组或墓地存在不受王家长眠之谷影响的对应怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	local ct1=2
	if not b1 then ct1=3 end
	local ct2=3
	if not b2 then ct2=2 end
	if ct2<ct1 then return end
	-- 提示选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local rg=sg:Select(tp,ct1,ct2,nil)
	if rg:GetCount()>0 then
		local hg=rg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_DECK)
		local og=rg-hg
		-- 给对方确认选中的手卡或卡组的卡
		Duel.ConfirmCards(1-tp,hg)
		-- 显示选中的场上或墓地的卡
		Duel.HintSelection(og)
		if hg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0 then
			-- 洗切手牌
			Duel.ShuffleHand(tp)
		end
	end
	if rg:GetCount()==2 then
		local c=e:GetHandler()
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只8星以下除效果怪兽外的融合怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 特殊召唤选中的融合怪兽
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- ●2张：除效果怪兽外的1只8星以下的融合怪兽从额外卡组当作通常怪兽卡使用特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))  --"当作通常怪兽卡使用"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_CARD_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(TYPE_NORMAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	elseif rg:GetCount()==3 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只「塞尼特」怪兽或从墓地选择1只通常怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 判断确认的卡中是否包含手卡且可以抽卡，由玩家选择是否抽1张卡
	if rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.IsPlayerCanDraw(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否抽卡？"
		-- 中断效果处理（分割前后时点）
		Duel.BreakEffect()
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
