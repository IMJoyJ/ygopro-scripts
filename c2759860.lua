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
-- 过滤函数，用于判断是否为场上表侧表示的灰篮卡
function c2759860.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd1)
end
-- 效果发动时的取对象处理，检查是否满足破坏效果的对象条件
function c2759860.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1张灰篮卡
	if chk==0 then return Duel.IsExistingTarget(c2759860.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张灰篮卡作为破坏对象
	local g1=Duel.SelectTarget(tp,c2759860.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时要破坏的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理函数，执行破坏操作
function c2759860.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的对象卡组，并筛选出与该效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的卡组进行破坏处理
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 检索效果发动条件，判断是否为自己的回合
function c2759860.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数，用于判断是否为可加入手牌的灰篮卡
function c2759860.filter(c)
	return c:IsSetCard(0xd1) and c:IsAbleToHand()
end
-- 检索效果发动时的处理函数，检查卡组中是否存在满足条件的卡
function c2759860.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张灰篮卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2759860.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要加入手牌的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理函数，执行将卡加入手牌的操作
function c2759860.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张灰篮卡作为加入手牌的对象
	local g=Duel.SelectMatchingCard(tp,c2759860.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
