--劫火の三幻魔－神炎皇ウリア
-- 效果：
-- 这张卡不能通常召唤，用「三幻魔」卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「三幻魔」陷阱卡加入手卡。那之后，选自己1张手卡丢弃。
-- ②：这张卡的攻击力·守备力上升双方墓地的陷阱卡数量×1000。
-- ③：自己·对方回合1次，以场上1张魔法·陷阱卡为对象才能发动（双方不能对应这个发动把效果发动）。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册苏生限制，限制只能用「三幻魔」卡效果召唤的效果，①的公开手牌检索并丢弃手牌的效果，②的根据双方墓地陷阱数增加攻防的效果，以及③的主动破坏魔陷效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「三幻魔」卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「三幻魔」陷阱卡加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升双方墓地的陷阱卡数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合1次，以场上1张魔法·陷阱卡为对象才能发动（双方不能对应这个发动把效果发动）。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 限制本卡的特殊召唤条件：必须是由「三幻魔」卡的效果才能进行特殊召唤
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x1144)
end
-- ①效果的发动代价：确认手卡中的这张卡未公开（给对方观看）
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤卡组中符合条件的「三幻魔」陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1144) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检查：确认卡组里存在可以检索的「三幻魔」陷阱卡，并设置检索与丢弃手牌的效果操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时，检查卡组中是否存在符合条件的「三幻魔」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- ①效果的效果处理：从卡组检索1张「三幻魔」陷阱卡加入手牌并向对方确认，之后玩家必须选择1张手卡丢弃
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张符合条件的「三幻魔」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡加入到玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方确认
		Duel.ConfirmCards(1-tp,g)
		-- 玩家选择自己手卡中的1张可以丢弃的卡片
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 洗切玩家手牌（因有检索及可能丢弃的变动）
			Duel.ShuffleHand(tp)
			-- 将选中的手卡作为效果处理丢弃并送入墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- ②效果的攻击力/守备力增加数值判定逻辑：计算双方墓地中的陷阱卡数量
function s.value(e,c)
	-- 获取双方墓地中陷阱卡的总数，并计算乘以1000的增益值
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_TRAP)*1000
end
-- 过滤场上可以作为破坏对象的魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果的发动准备与合法性检查：选择场上1张魔法·陷阱卡作为效果的对象，并限制对方不能对应本次发动来发动效果
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.desfilter(chkc) end
	-- 效果发动时，检查场上是否存在可以作为破坏对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从场上选择1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏指定的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 限制对方连锁：双方不能对应这个效果的发动将其他卡的效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- ③效果的效果处理：将作为对象的魔法·陷阱卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中作为破坏对象的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将作为对象的魔法·陷阱卡以效果破坏的方式送入墓地
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
