--トロイメア・ユニコーン
-- 效果：
-- 卡名不同的怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡回到卡组。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
-- ②：只要互相连接状态的「幻崩」怪兽存在，自己抽卡阶段的通常抽卡数量变成那些「幻崩」怪兽种类的数量。
function c38342335.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2张满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,nil,c38342335.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡回到卡组。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38342335,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,38342335)
	e1:SetCondition(c38342335.tdcon)
	e1:SetCost(c38342335.tdcost)
	e1:SetTarget(c38342335.tdtg)
	e1:SetOperation(c38342335.tdop)
	c:RegisterEffect(e1)
	-- ②：只要互相连接状态的「幻崩」怪兽存在，自己抽卡阶段的通常抽卡数量变成那些「幻崩」怪兽种类的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c38342335.drcon)
	e2:SetValue(c38342335.drval)
	c:RegisterEffect(e2)
end
-- 连接素材中卡名不同的怪兽数量必须等于连接素材总数
function c38342335.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 效果发动时，确认此卡是否为连接召唤
function c38342335.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 支付效果代价，丢弃1张手牌
function c38342335.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果目标，选择场上1张可送回卡组的卡
function c38342335.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	-- 检查场上是否存在可送回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张可送回卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，确定要送回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_TODECK)
		e:SetLabel(0)
	end
end
-- 处理效果的发动，将目标卡送回卡组并可能抽卡
function c38342335.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡是否仍然在场上且满足效果处理条件
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 确认此卡是否为互相连接状态且玩家可以抽卡
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(38342335,1)) then  --"是否抽卡？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		if tc:IsLocation(LOCATION_DECK) and tc:IsControler(tp) then
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
		end
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数，筛选场上正面表示的「幻崩」怪兽且为互相连接状态
function c38342335.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x112) and c:GetMutualLinkedGroupCount()>0
end
-- 判断是否存在互相连接状态的「幻崩」怪兽
function c38342335.drcon(e)
	-- 统计场上互相连接状态的「幻崩」怪兽数量
	return Duel.GetMatchingGroupCount(c38342335.drfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>0
end
-- 计算抽卡数量，等于场上互相连接状态的「幻崩」怪兽种类数
function c38342335.drval(e)
	-- 获取场上所有互相连接状态的「幻崩」怪兽
	local g=Duel.GetMatchingGroup(c38342335.drfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetClassCount(Card.GetCode)
end
