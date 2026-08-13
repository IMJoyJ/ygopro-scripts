--ガスタの疾風 リーズ
-- 效果：
-- 让1张手卡回到卡组最下面，选择对方场上存在的1只怪兽和自己场上表侧表示存在的1只名字带有「薰风」的怪兽发动。选择的怪兽的控制权交换。这个效果1回合只能使用1次。
function c36331074.initial_effect(c)
	-- 让1张手卡回到卡组最下面，选择对方场上存在的1只怪兽和自己场上表侧表示存在的1只名字带有「薰风」的怪兽发动。选择的怪兽的控制权交换。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36331074,0))  --"控制权交换"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c36331074.cost)
	e1:SetTarget(c36331074.target)
	e1:SetOperation(c36331074.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：处理“让1张手卡回到卡组最下面”这一发动代价，检查、选择并送还手牌。
function c36331074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：确认手牌中存在至少1张可以作为代价返回卡组的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，告知玩家需要选择1张要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择1张可作为代价的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌以代价形式送回持有者卡组的最下面。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 自己方怪兽的筛选条件：必须是表侧表示、名字带有「薰风」、能改变控制权，且其控制者场上有足够空位容纳交换来的怪兽。
function c36331074.filter1(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0x10)
		-- 追加判断：该怪兽必须能够改变控制权，并且其控制者在交换后仍有可用怪兽区。
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 对方方怪兽的筛选条件：选择对方场上的1只怪兽，要求能改变控制权，且其控制者场上有足够空位容纳交换来的怪兽。
function c36331074.filter2(c)
	local tp=c:GetControler()
	-- 该怪兽必须能改变控制权，且其控制者在交换后仍有可用怪兽区。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 发动时选择目标的函数：确认可以选择对方场上1只怪兽和自己场上1只表侧薰风怪兽，并将选中的2只怪兽设为效果对象。
function c36331074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动检查：确认对方场上有1只满足条件的可选怪兽。
	if chk==0 then return Duel.IsExistingTarget(c36331074.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 发动检查：确认自己场上有1只满足条件的表侧薰风怪兽。
		and Duel.IsExistingTarget(c36331074.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示，告知玩家选择自己场上要交换控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只满足条件的薰风怪兽，并设置为效果对象。
	local g1=Duel.SelectTarget(tp,c36331074.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示选择提示，告知玩家选择对方场上要交换控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽，并设置为效果对象。
	local g2=Duel.SelectTarget(tp,c36331074.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：本次连锁将进行控制权交换，对象为已选择的2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理函数：获取连锁记录的对象，若2只怪兽仍与效果关联，则交换它们的控制权。
function c36331074.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的对象卡组（即2只怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换两只怪兽的控制权。
		Duel.SwapControl(a,b)
	end
end
