--紅涙の魔ラクリモーサ
-- 效果：
-- 这个卡名在规则上也当作「刻魔」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「红泪之魔 落泪之日」以外的1张「刻魔」卡送去墓地。
-- ②：对方回合，这张卡在墓地存在的场合，以自己墓地1只「刻魔」连接怪兽为对象才能发动。这张卡回到卡组，作为对象的怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册效果，包含①②两个效果，①为通常召唤或特殊召唤时发动的效果，②为对方回合墓地存在时可发动的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「红泪之魔 落泪之日」以外的1张「刻魔」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方回合，这张卡在墓地存在的场合，以自己墓地1只「刻魔」连接怪兽为对象才能发动。这张卡回到卡组，作为对象的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选卡组中非自身且为「刻魔」的卡
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1b0) and c:IsAbleToGrave()
end
-- 效果处理时的判定函数，检查是否满足发动条件并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「刻魔」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断是否为对方回合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是自己
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，用于筛选墓地中满足条件的「刻魔」连接怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x1b0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果处理时的判定函数，检查是否满足发动条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查墓地中是否存在满足条件的「刻魔」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己场上是否有空位且该卡可回到卡组
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsAbleToDeck() end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将该卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置操作信息，表示将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将该卡返回卡组并特殊召唤目标怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断该卡是否仍在场上且未被王家长眠之谷影响且已成功返回卡组
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK)
		-- 判断场上是否有空位且目标怪兽满足条件
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
