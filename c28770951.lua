--銀河の修道師
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「光子」超量怪兽或者「银河」超量怪兽为对象才能发动。把手卡的这张卡在那只怪兽下面重叠作为超量素材。
-- ②：这张卡召唤·特殊召唤成功的场合，从自己墓地的「光子」卡以及「银河」卡之中以合计5张为对象才能发动（同名卡最多1张）。那些卡加入卡组洗切。那之后，自己从卡组抽2张。
function c28770951.initial_effect(c)
	-- ①：以自己场上1只「光子」超量怪兽或者「银河」超量怪兽为对象才能发动。把手卡的这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28770951,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,28770951)
	e1:SetTarget(c28770951.mattg)
	e1:SetOperation(c28770951.matop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，从自己墓地的「光子」卡以及「银河」卡之中以合计5张为对象才能发动（同名卡最多1张）。那些卡加入卡组洗切。那之后，自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28770951,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,28770951)
	e2:SetTarget(c28770951.drtg)
	e2:SetOperation(c28770951.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标是否为表侧表示的「光子」或「银河」超量怪兽
function c28770951.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_XYZ)
end
-- 设置效果的目标为满足条件的场上怪兽
function c28770951.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28770951.matfilter(chkc) end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c28770951.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c28770951.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果的执行操作，将手牌叠放至目标怪兽下方
function c28770951.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将手牌作为超量素材叠放至目标怪兽
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 过滤函数，用于判断墓地中的卡是否为「光子」或「银河」卡且能送入卡组
function c28770951.filter(c,e)
	return c:IsSetCard(0x55,0x7b) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 设置效果的目标为满足条件的墓地卡片
function c28770951.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28770951.filter(chkc,e) end
	-- 获取满足条件的墓地卡片组
	local g=Duel.GetMatchingGroup(c28770951.filter,tp,LOCATION_GRAVE,0,nil,e)
	-- 检查是否满足选择5张不同卡名的条件并确认玩家可以抽2张卡
	if chk==0 then return g:GetClassCount(Card.GetCode)>=5 and Duel.IsPlayerCanDraw(tp,2) end
	-- 提示玩家选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置额外检查条件为卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 从满足条件的卡片中选择5张不同卡名的卡片
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,5,5)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	-- 设置当前效果处理的目标卡片
	Duel.SetTargetCard(sg)
	-- 设置效果处理的分类为将卡片送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
	-- 设置效果处理的分类为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 处理效果的执行操作，将目标卡片送入卡组并抽卡
function c28770951.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡片组并筛选出与效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将目标卡片送入卡组并洗切
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果送入卡组的卡片中有位于卡组的，则进行洗切
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果，使后续效果处理视为不同时处理
		Duel.BreakEffect()
		-- 让玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
