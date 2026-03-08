--ヴァイロン・マター
-- 效果：
-- 选择自己墓地存在的3张装备魔法卡发动。选择的卡加入卡组洗切，从以下效果选择1个适用。
-- ●从自己卡组抽1张卡。
-- ●对方场上存在的1张卡破坏。
function c41858121.initial_effect(c)
	-- 效果原文内容：选择自己墓地存在的3张装备魔法卡发动。选择的卡加入卡组洗切，从以下效果选择1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41858121.target)
	e1:SetOperation(c41858121.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出可以返回卡组的装备魔法卡
function c41858121.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToDeck()
end
-- 效果作用：判断是否满足发动条件，即自己墓地存在3张装备魔法卡，且自己可以抽卡或对方场上存在卡
function c41858121.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41858121.filter(chkc) end
	-- 效果作用：判断自己墓地是否存在3张装备魔法卡
	if chk==0 then return Duel.IsExistingTarget(c41858121.filter,tp,LOCATION_GRAVE,0,3,nil)
		-- 效果作用：判断自己是否可以抽卡且自己卡组存在卡
		and ((Duel.IsPlayerCanDraw(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0)
		-- 效果作用：判断对方场上是否存在卡
		or Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil))
	end
	-- 效果作用：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择3张装备魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c41858121.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 效果作用：设置效果处理信息，指定将3张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
-- 效果原文内容：●从自己卡组抽1张卡。/●对方场上存在的1张卡破坏。
function c41858121.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中被选择的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<=0 then return end
	-- 效果作用：将选中的卡返回卡组并洗切
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 效果作用：获取实际被操作的卡组
	local og=Duel.GetOperatedGroup()
	if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then return end
	-- 效果作用：洗切玩家卡组
	Duel.ShuffleDeck(tp)
	-- 效果作用：中断当前效果处理，使后续处理视为错时点
	Duel.BreakEffect()
	local op=0
	-- 效果作用：判断玩家是否可以抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1)
	-- 效果作用：判断对方场上是否存在卡
	local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	-- 效果作用：提示玩家选择效果选项
	Duel.Hint(HINT_SELECTMSG,tp,0)
	-- 效果作用：当两个效果都可选时，让玩家选择其中一个
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(41858121,0),aux.Stringid(41858121,1))  --"从自己卡组抽1张卡。/对方场上存在的1张卡破坏。"
	-- 效果作用：当只有抽卡效果可选时，让玩家选择抽卡
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(41858121,0))  --"从自己卡组抽1张卡。"
	-- 效果作用：当只有破坏效果可选时，让玩家选择破坏
	elseif b2 then Duel.SelectOption(tp,aux.Stringid(41858121,1)) op=1  --"对方场上存在的1张卡破坏。"
	else return end
	if op==0 then
		-- 效果作用：从自己卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		-- 效果作用：提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 效果作用：选择对方场上1张卡作为破坏对象
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 效果作用：破坏选中的卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
