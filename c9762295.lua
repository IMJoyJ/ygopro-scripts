--光帰の旅－『セネト』
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：选自己的手卡·卡组·场上（表侧表示）·墓地的通常怪兽卡的以下数量，给双方确认。那之后，那个数量的以下效果适用。这个效果把手卡的卡确认的场合，再让自己可以抽1张。
-- ●2张：除效果怪兽外的1只8星以下的融合怪兽从额外卡组当作通常怪兽卡使用特殊召唤。
-- ●3张：卡组1只「塞尼特」怪兽或者自己墓地1只通常怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册通常魔法发动效果（1回合1张誓约限制），确认己方手卡·卡组·场上表侧·墓地的2张或3张通常怪兽卡并适用对应特召效果，若确认了手卡还可抽1张
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。 ①：选自己的手卡·卡组·场上（表侧表示）·墓地的通常怪兽卡的以下数量，给双方确认。那之后，那个数量的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：检查卡片是否为表侧表示（含手卡·卡组·墓地）且同时具有通常与怪兽卡片类型（通常怪兽卡）
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 筛选条件（2张分支）：检查额外卡组怪兽是否为非效果怪兽、8星以下融合怪兽，且可特殊召唤并有对应额外怪兽区可用空位
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(8)
		-- 确认该融合怪兽可被特殊召唤且从额外卡组出场的可用格子数大于0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 筛选条件（3张分支）：检查可特殊召唤的卡片，若在卡组则要求为「塞尼特」怪兽，若在墓地则要求为通常怪兽
function s.spfilter2(c,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return c:IsSetCard(0x1eb)
	else
		return c:IsType(TYPE_NORMAL)
	end
end
-- 发动检测：统计己方手卡·墓地·场上·卡组的通常怪兽卡数量，判断能否执行2张分支（额外特召）或3张分支（卡组/墓地特召）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计己方手卡·墓地·场上（表侧）·卡组中全部通常怪兽卡的数量
	local ct=Duel.GetMatchingGroupCount(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,nil)
	-- 判断2张分支是否可执行：通常怪兽卡不少于2张且额外卡组有符合条件的8星以下非效果融合怪兽
	local b1=ct>=2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	-- 判断3张分支前半条件：通常怪兽卡不少于3张且己方主要怪兽区有空位
	local b2=ct>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断3张分支后半条件：己方卡组有「塞尼特」怪兽或墓地有通常怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
end
-- 效果处理流程：让己方选择2或3张通常怪兽卡给双方确认并适用对应特殊召唤分支，若确认了手卡的卡则可选再抽1张卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方手卡·墓地·场上（表侧）·卡组中全部通常怪兽卡集合
	local sg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,nil)
	-- 处理时再次判断2张分支是否可执行
	local b1=sg:GetCount()>=2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	-- 处理时再次判断3张分支是否满足数量与空位条件
	local b2=sg:GetCount()>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 处理时结合王家长眠之谷过滤判断卡组·墓地是否存在可特召的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	local ct1=2
	if not b1 then ct1=3 end
	local ct2=3
	if not b2 then ct2=2 end
	if ct2<ct1 then return end
	-- 向己方提示选择要给对方确认的通常怪兽卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local rg=sg:Select(tp,ct1,ct2,nil)
	if rg:GetCount()>0 then
		local hg=rg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_DECK)
		local og=rg-hg
		-- 向对方公开确认所选的手卡与卡组中的通常怪兽卡
		Duel.ConfirmCards(1-tp,hg)
		-- 高亮提示所选的场上与墓地中的通常怪兽卡
		Duel.HintSelection(og)
		if hg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0 then
			-- 在确认了手卡之后洗切己方手卡
			Duel.ShuffleHand(tp)
		end
	end
	if rg:GetCount()==2 then
		local c=e:GetHandler()
		-- 向己方提示选择要从额外卡组特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从额外卡组选择1只8星以下非效果融合怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 执行分步特殊召唤，将所选融合怪兽以表侧表示特殊召唤到己方场上
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- ●2张：除效果怪兽外的1只8星以下的融合怪兽从额外卡组当作通常怪兽卡使用特殊召唤。 ●3张：卡组1只「塞尼特」怪兽或者自己墓地1只通常怪兽特殊召唤。 这个效果把手卡的卡确认的场合，再让自己可以抽1张。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))  --"当作通常怪兽卡使用"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_CARD_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(TYPE_NORMAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
		-- 完成分步特殊召唤并统一触发召唤相关时点
		Duel.SpecialSummonComplete()
	elseif rg:GetCount()==3 then
		-- 向己方提示选择要从卡组或墓地特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从己方卡组或墓地（经王家长眠之谷过滤）选择1只满足3张分支条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 若之前确认的卡中包含手卡且己方可以抽卡，询问己方是否再抽1张
	if rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.IsPlayerCanDraw(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否抽卡？"
		-- 中断效果处理，使后续抽卡与前面的特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 以效果使己方从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
