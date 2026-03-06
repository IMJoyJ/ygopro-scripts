--VS ラゼン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只战士族以外的「征服斗魂」怪兽加入手卡。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●炎：这个回合，这张卡不会被效果破坏。
-- ●炎·暗：和这张卡相同纵列的其他怪兽全部破坏。
function c29302858.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只战士族以外的「征服斗魂」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29302858,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,29302858)
	e1:SetTarget(c29302858.thtg)
	e1:SetOperation(c29302858.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●炎：这个回合，这张卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29302858,1))  --"展示炎属性的怪兽"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,29302859)
	e3:SetCost(c29302858.indescost)
	e3:SetTarget(c29302858.indestg)
	e3:SetOperation(c29302858.indesop)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●炎·暗：和这张卡相同纵列的其他怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29302858,2))  --"展示炎·暗属性的怪兽"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,29302859)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(c29302858.descost)
	e4:SetTarget(c29302858.destg)
	e4:SetOperation(c29302858.desop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的卡片组，即战士族以外的「征服斗魂」怪兽
function c29302858.thfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 判断是否满足发动条件，即卡组存在满足条件的怪兽且该玩家未发动过此效果
function c29302858.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29302858.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断该玩家是否已发动过此效果
		and Duel.GetFlagEffect(tp,29302858)==0 end
	-- 注册标识效果，防止同一连锁发动
	Duel.RegisterFlagEffect(tp,29302858,RESET_CHAIN,0,1)
	-- 设置操作信息，用于连锁检测
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动，选择并加入手牌
function c29302858.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c29302858.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选手牌中炎属性且未公开的怪兽
function c29302858.indescfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 处理效果发动，确认手牌中炎属性怪兽并洗切手牌
function c29302858.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c29302858.indescfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的手牌
	local g=Duel.SelectMatchingCard(tp,c29302858.indescfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选卡
	Duel.ConfirmCards(1-tp,g)
	-- 触发事件，用于记录效果使用
	Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 洗切玩家手牌
	Duel.ShuffleHand(tp)
end
-- 处理效果发动，判断是否可发动
function c29302858.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断该玩家是否已发动过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,29302858)==0 end
	-- 注册标识效果，防止同一连锁发动
	Duel.RegisterFlagEffect(tp,29302858,RESET_CHAIN,0,1)
end
-- 处理效果发动，使此卡在本回合不会被效果破坏
function c29302858.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 使此卡在本回合不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	c:RegisterEffect(e1)
end
-- 筛选手牌中炎·暗属性且未公开的怪兽
function c29302858.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 处理效果发动，确认手牌中炎·暗属性怪兽并洗切手牌
function c29302858.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的手牌组
	local g=Duel.GetMatchingGroup(c29302858.descfilter,tp,LOCATION_HAND,0,nil)
	-- 判断是否存在满足条件的两张手牌组合
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK) end
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的两张手牌
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK)
	-- 向对方确认所选卡
	Duel.ConfirmCards(1-tp,sg)
	-- 触发事件，用于记录效果使用
	Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 洗切玩家手牌
	Duel.ShuffleHand(tp)
end
-- 处理效果发动，判断是否可发动
function c29302858.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 判断是否存在满足条件的怪兽且该玩家未发动过此效果
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,29302858)==0 end
	-- 注册标识效果，防止同一连锁发动
	Duel.RegisterFlagEffect(tp,29302858,RESET_CHAIN,0,1)
	-- 设置操作信息，用于连锁检测
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 处理效果发动，破坏相同纵列的怪兽
function c29302858.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=c:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 破坏满足条件的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
