--セフィラの神託
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡的发动时从卡组把1只「神数」怪兽加入手卡。
-- ②：以下怪兽使用「神数」怪兽作仪式召唤或者用「神数」怪兽为素材作特殊召唤时，自己让各自效果1回合各能发动1次。
-- ●仪式：场上1只怪兽回到卡组。
-- ●融合：手卡1只怪兽特殊召唤。
-- ●同调：卡组1只怪兽在卡组最上面放置。
-- ●超量：从卡组抽1张，那之后丢弃1张手卡。
function c32354768.initial_effect(c)
	-- 效果原文内容：①：这张卡的发动时从卡组把1只「神数」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32354768+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32354768.target)
	e1:SetOperation(c32354768.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：●仪式：场上1只怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32354768,0))  --"场上1只怪兽回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1)
	e2:SetCondition(c32354768.effcon)
	e2:SetTarget(c32354768.tdtg)
	e2:SetOperation(c32354768.tdop)
	e2:SetLabel(TYPE_RITUAL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(32354768,1))  --"手卡1只怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetTarget(c32354768.sptg)
	e3:SetOperation(c32354768.spop)
	e3:SetLabel(TYPE_FUSION)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(32354768,2))  --"卡组1只怪兽在卡组最上面放置"
	e4:SetCategory(0)
	e4:SetTarget(c32354768.sttg)
	e4:SetOperation(c32354768.stop)
	e4:SetLabel(TYPE_SYNCHRO)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetDescription(aux.Stringid(32354768,3))  --"从卡组抽1张，那之后丢弃1张手卡"
	e5:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e5:SetTarget(c32354768.drtg)
	e5:SetOperation(c32354768.drop)
	e5:SetLabel(TYPE_XYZ)
	c:RegisterEffect(e5)
	-- 效果原文内容：②：以下怪兽使用「神数」怪兽作仪式召唤或者用「神数」怪兽为素材作特殊召唤时，自己让各自效果1回合各能发动1次。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(c32354768.valcheck)
	c:RegisterEffect(e6)
end
-- 规则层面操作：定义过滤函数，用于判断是否为神数卡组的怪兽
function c32354768.mtfilter1(c)
	return c:IsSetCard(0xc4) and c:IsType(TYPE_MONSTER)
end
-- 规则层面操作：定义过滤函数，用于判断是否为神数卡组的融合怪兽
function c32354768.mtfilter2(c)
	return c:IsFusionSetCard(0xc4) and c:IsFusionType(TYPE_MONSTER)
end
-- 规则层面操作：定义过滤函数，用于判断是否为神数卡组的同调怪兽
function c32354768.mtfilter3(c)
	return c:IsSetCard(0xc4) and c:IsSynchroType(TYPE_MONSTER)
end
-- 规则层面操作：定义过滤函数，用于判断是否为神数卡组的超量怪兽
function c32354768.mtfilter4(c)
	return c:IsSetCard(0xc4) and c:IsXyzType(TYPE_MONSTER)
end
-- 规则层面操作：根据召唤类型和素材判断是否满足条件并注册标志效果
function c32354768.valcheck(e,c)
	local g=c:GetMaterial()
	if c:IsType(TYPE_RITUAL) and g:IsExists(c32354768.mtfilter1,1,nil) then
		c:RegisterFlagEffect(32354768,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	elseif c:IsType(TYPE_FUSION) and g:IsExists(c32354768.mtfilter2,1,nil) then
		c:RegisterFlagEffect(32354768,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	elseif c:IsType(TYPE_SYNCHRO) and g:IsExists(c32354768.mtfilter3,1,nil) then
		c:RegisterFlagEffect(32354768,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	elseif c:IsType(TYPE_XYZ) and g:IsExists(c32354768.mtfilter4,1,nil) then
		c:RegisterFlagEffect(32354768,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 规则层面操作：定义过滤函数，用于检索满足条件的神数怪兽
function c32354768.filter(c)
	return c:IsSetCard(0xc4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果处理时的检索条件
function c32354768.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32354768.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置效果处理信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：执行效果处理，选择并加入手牌
function c32354768.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c32354768.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：确认对方看到所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 规则层面操作：判断是否满足触发条件
function c32354768.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():IsType(e:GetLabel()) and eg:GetFirst():GetFlagEffect(32354768)~=0
end
-- 规则层面操作：设置效果处理时的检索条件
function c32354768.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 规则层面操作：设置效果处理信息，表示将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 规则层面操作：执行效果处理，选择并送回卡组
function c32354768.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面操作：选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面操作：将卡送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 规则层面操作：定义过滤函数，用于判断是否可以特殊召唤
function c32354768.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置效果处理时的检索条件
function c32354768.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c32354768.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面操作：设置效果处理信息，表示将卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面操作：执行效果处理，选择并特殊召唤
function c32354768.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c32354768.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面操作：设置效果处理时的检索条件
function c32354768.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_MONSTER) end
end
-- 规则层面操作：执行效果处理，选择并放置在卡组最上方
function c32354768.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要放置在卡组最上方的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(32354768,4))  --"选择要放置在卡组最上方的怪兽"
	-- 规则层面操作：选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面操作：洗切卡组
		Duel.ShuffleDeck(tp)
		-- 规则层面操作：将卡移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 规则层面操作：确认卡组最上方的卡
		Duel.ConfirmDecktop(tp,1)
	end
end
-- 规则层面操作：设置效果处理时的检索条件
function c32354768.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面操作：设置效果处理信息，表示丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 规则层面操作：设置效果处理信息，表示抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面操作：执行效果处理，抽卡并丢弃手牌
function c32354768.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查是否成功抽卡
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 规则层面操作：洗切手牌
		Duel.ShuffleHand(tp)
		-- 规则层面操作：中断当前效果
		Duel.BreakEffect()
		-- 规则层面操作：丢弃1张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
