--紅涙の魔ラクリモーサ
-- 效果：
-- 这个卡名在规则上也当作「刻魔」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「红泪之魔 落泪之日」以外的1张「刻魔」卡送去墓地。
-- ②：对方回合，这张卡在墓地存在的场合，以自己墓地1只「刻魔」连接怪兽为对象才能发动。这张卡回到卡组，作为对象的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册本卡效果：e1/e2构成①效果，在召唤/特殊召唤时从卡组将1张「刻魔」卡送去墓地（1回合1次）；e3构成②效果，在对方回合墓地存在时，以自己墓地1只「刻魔」连接怪兽为对象，自身回卡组并将对象特殊召唤（1回合1次）。
function s.initial_effect(c)
	-- ①效果中“这张卡召唤的场合才能发动。从卡组把「红泪之魔 落泪之日」以外的1张「刻魔」卡送去墓地。”
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
	-- ②效果原文：对方回合，这张卡在墓地存在的场合，以自己墓地1只「刻魔」连接怪兽为对象才能发动。这张卡回到卡组，作为对象的怪兽特殊召唤。
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
-- 过滤函数：筛选不是本卡名（id）、属于「刻魔」字段（0x1b0）且能够送去墓地的卡。
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1b0) and c:IsAbleToGrave()
end
-- ①效果的发动条件与操作信息：chk==0时检查卡组是否存在满足tgfilter的卡；满足后设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组存在至少1张满足tgfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组送去墓地，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张满足条件的「刻魔」卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足s.tgfilter的卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数：仅在对方回合允许发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是本卡控制者，即处于对方回合。
	return Duel.GetTurnPlayer()==1-tp
end
-- 特殊召唤对象过滤函数：要求是「刻魔」连接怪兽，且可以被当前效果特殊召唤（表侧表示）。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x1b0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ②效果的取对象处理与发动条件判断：检查选择的对象位于己方墓地且满足spfilter；发动条件为墓地存在对象、主要怪兽区有空位、自身能回卡组。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1张满足spfilter的「刻魔」连接怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 同时确认自己主要怪兽区有空位，且本卡（在墓地）能够回到卡组。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsAbleToDeck() end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「刻魔」连接怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本卡自身将回到卡组并洗牌。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置操作信息：对象怪兽将被特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：若本卡成功回到卡组且对象仍关联，则将对象特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果对象（已选择的墓地「刻魔」连接怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 处理条件判定：本卡与效果仍关联、不受王家长眠之谷影响，将其送回卡组洗牌，且确实返回卡组。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK)
		-- 继续判定：自己主要怪兽区有空位，且对象仍与效果关联、不受王家长眠之谷影响。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
