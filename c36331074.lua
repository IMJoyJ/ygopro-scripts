--ガスタの疾風 リーズ
-- 效果：
-- 让1张手卡回到卡组最下面，选择对方场上存在的1只怪兽和自己场上表侧表示存在的1只名字带有「薰风」的怪兽发动。选择的怪兽的控制权交换。这个效果1回合只能使用1次。
function c36331074.initial_effect(c)
	-- 效果描述：控制权交换
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
-- 让1张手卡回到卡组最下面
function c36331074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可送入卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张手牌送入卡组底端
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送入卡组底端作为代价
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 过滤自己场上表侧表示且名字带有「薰风」的怪兽
function c36331074.filter1(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0x10)
		-- 确保怪兽可以改变控制权且有可用怪兽区
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤对方场上的怪兽
function c36331074.filter2(c)
	local tp=c:GetControler()
	-- 确保怪兽可以改变控制权且有可用怪兽区
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 设置效果发动时的条件：对方场上存在怪兽，自己场上存在名字带有「薰风」的怪兽
function c36331074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在可选择的怪兽
	if chk==0 then return Duel.IsExistingTarget(c36331074.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在名字带有「薰风」的怪兽
		and Duel.IsExistingTarget(c36331074.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上名字带有「薰风」的怪兽
	local g1=Duel.SelectTarget(tp,c36331074.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的怪兽
	local g2=Duel.SelectTarget(tp,c36331074.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时的操作信息，指定将交换控制权的怪兽数量为2
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理函数：交换两个目标怪兽的控制权
function c36331074.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换两个目标怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
