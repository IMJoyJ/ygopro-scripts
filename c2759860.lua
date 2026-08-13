--グレイドル・インパクト
-- 效果：
-- 「灰篮撞击」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以这张卡以外的自己场上1张「灰篮」卡和对方场上1张卡为对象才能把这个效果发动。那些卡破坏。
-- ②：自己结束阶段才能把这个效果发动。从卡组把1张「灰篮」卡加入手卡。
function c2759860.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以这张卡以外的自己场上1张「灰篮」卡和对方场上1张卡为对象才能把这个效果发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,2759860)
	e2:SetTarget(c2759860.destg)
	e2:SetOperation(c2759860.desop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段才能把这个效果发动。从卡组把1张「灰篮」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,2759860)
	e3:SetCondition(c2759860.thcon)
	e3:SetTarget(c2759860.thtg)
	e3:SetOperation(c2759860.thop)
	c:RegisterEffect(e3)
end
-- 定义①效果中“自己场上表侧表示的「灰篮」卡”的筛选条件，用于选择破坏对象。
function c2759860.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd1)
end
-- ①效果发动时的取对象处理：先确认自己场上存在此卡以外的表侧表示「灰篮」卡，且对方场上有可选的卡。
function c2759860.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1张此卡以外的表侧表示「灰篮」卡作为对象候选。
	if chk==0 then return Duel.IsExistingTarget(c2759860.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上是否存在1张可以作为对象（任意卡）的卡。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的提示信息，准备进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张符合条件的「灰篮」卡（此卡以外）作为①效果的对象。
	local g1=Duel.SelectTarget(tp,c2759860.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 向操作者显示“请选择要破坏的卡”的提示信息，准备选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡（任意卡）作为①效果的另一个对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将本次连锁的处理信息设置为“破坏2张对象卡”，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ①效果处理时，取出取对象阶段选择的卡，若仍与效果相关则将其破坏。
function c2759860.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中记录的对象卡，并筛选出仍与本次效果相关的卡（未被无效、未离场等）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的对象卡以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：自己结束阶段（当前回合玩家是自己）。
function c2759860.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为这张卡的控制者（即自己的结束阶段）。
	return Duel.GetTurnPlayer()==tp
end
-- 定义卡组中可检索的「灰篮」卡的筛选条件：卡名含有「灰篮」且可以被加入手卡。
function c2759860.filter(c)
	return c:IsSetCard(0xd1) and c:IsAbleToHand()
end
-- ②效果发动前的目标判定：确认卡组中存在符合条件的「灰篮」卡，并设置处理信息为“从卡组检索加入手卡”。
function c2759860.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的「灰篮」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c2759860.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将执行从卡组将1张「灰篮」卡加入手卡的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时，从卡组挑选1张「灰篮」卡加入手牌，并向对方确认。
function c2759860.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「灰篮」卡。
	local g=Duel.SelectMatchingCard(tp,c2759860.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
