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
-- 过滤条件：卡组中战士族以外的「征服斗魂」怪兽
function c29302858.thfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果①的发动靶子（Target）函数：检查卡组是否存在符合条件的卡，以及当前连锁中玩家未曾发动过此卡的效果
function c29302858.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29302858.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查当前连锁中玩家是否未曾发动过此卡的效果（用于同一连锁上不能发动的限制）
		and Duel.GetFlagEffect(tp,29302858)==0 end
	-- 在当前连锁中注册效果标记，用于限制同一连锁上不能重复发动此卡效果
	Duel.RegisterFlagEffect(tp,29302858,RESET_CHAIN,0,1)
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的执行（Operation）函数：从卡组选择1只战士族以外的「征服斗魂」怪兽加入手卡并展示给对方确认
function c29302858.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要检索的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c29302858.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：手卡中非公开的炎属性怪兽
function c29302858.indescfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 效果②「炎」分支的发动代价（Cost）函数：展示手卡中的1只炎属性怪兽
function c29302858.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张未展示过的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29302858.indescfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择展示给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张满足过滤条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c29302858.indescfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方展示确认选择的炎属性怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 若自身是「征服斗魂」卡片，则触发对应的手卡展示事件以支持本系列其他卡片的效果触发
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 效果②「炎」分支的发动靶子（Target）函数：检查同一连锁上是否没有发动过此卡的效果，并注册限制标记
function c29302858.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家在当前连锁中是否没有注册过该卡的效果发动标记
	if chk==0 then return Duel.GetFlagEffect(tp,29302858)==0 end
	-- 在当前连锁中注册效果标记，用于限制同一连锁上不能重复发动此卡效果
	Duel.RegisterFlagEffect(tp,29302858,RESET_CHAIN,0,1)
end
-- 效果②「炎」分支的执行（Operation）函数：给此卡添加在这个回合内不会被效果破坏的永续效果
function c29302858.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 这个回合，这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中未展示的炎属性或暗属性怪兽
function c29302858.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 效果②「炎·暗」分支的发动代价（Cost）函数：展示手卡中炎属性和暗属性怪兽各1只
function c29302858.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有未展示的炎属性和暗属性怪兽
	local g=Duel.GetMatchingGroup(c29302858.descfilter,tp,LOCATION_HAND,0,nil)
	-- 检查手卡中是否能选出炎属性与暗属性各1只的怪兽组合
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK) end
	-- 提示玩家选择展示给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从符合条件的卡中选择炎属性和暗属性各1只的怪兽组合
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK)
	-- 向对方展示所选的炎属性和暗属性怪兽进行确认
	Duel.ConfirmCards(1-tp,sg)
	-- 若自身是「征服斗魂」卡片，则触发对应的手卡展示事件以支持本系列其他卡片的效果触发
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 效果②「炎·暗」分支的发动靶子（Target）函数：检查相同纵列是否存在怪兽，并确认同一连锁未曾发动过此卡效果，设置破坏的操作信息
function c29302858.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 检查与这张卡相同纵列的其他怪兽区是否存在怪兽，以及当前连锁中玩家未曾发动过此卡的效果
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,29302858)==0 end
	-- 在当前连锁中注册效果发动标记，限制同一连锁内不能发动此卡效果
	Duel.RegisterFlagEffect(tp,29302858,RESET_CHAIN,0,1)
	-- 设置连锁处理的操作信息：破坏相同纵列的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果②「炎·暗」分支的执行（Operation）函数：将与这张卡相同纵列的其他怪兽全部破坏
function c29302858.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=c:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 因效果破坏相同纵列的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
