--間炎星－コウカンショウ
-- 效果：
-- 名字带有「炎星」的4星怪兽×2
-- 把这张卡2个超量素材取除才能发动。选择自己的场上·墓地的名字带有「炎星」或者「炎舞」的卡合计2张和对方墓地或者对方场上表侧表示存在的卡合计2张回到持有者卡组。「闲炎星-红冠胜」的效果1回合只能使用1次。
function c58504745.initial_effect(c)
	-- 添加XYZ召唤手续：用2只4星的「炎星」怪兽进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x79),4,2)
	c:EnableReviveLimit()
	-- 把这张卡2个超量素材取除才能发动。选择自己的场上·墓地的名字带有「炎星」或者「炎舞」的卡合计2张和对方墓地或者对方场上表侧表示存在的卡合计2张回到持有者卡组。「闲炎星-红冠胜」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58504745,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,58504745)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c58504745.cost)
	e1:SetTarget(c58504745.target)
	e1:SetOperation(c58504745.operation)
	c:RegisterEffect(e1)
end
-- 代价处理函数：检查并取除这张卡的2个超量素材
function c58504745.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤函数1：自己场上表侧表示或自己墓地中，名字带有「炎星」或「炎舞」且能回到卡组的卡
function c58504745.filter1(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x79,0x7c) and c:IsAbleToDeck()
end
-- 过滤函数2：对方场上表侧表示或对方墓地中，能回到卡组的卡
function c58504745.filter2(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
-- 目标选择函数：判定并选择双方场上/墓地的对应卡片作为效果对象
function c58504745.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定自己场上（表侧表示）或墓地是否存在至少2张满足条件的「炎星」或「炎舞」卡片
	if chk==0 then return Duel.IsExistingTarget(c58504745.filter1,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,2,nil)
		-- 判定对方场上（表侧表示）或墓地是否存在至少2张可以回到卡组的卡片
		and Duel.IsExistingTarget(c58504745.filter2,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上或墓地的2张「炎星」或「炎舞」卡片作为效果对象
	local g1=Duel.SelectTarget(tp,c58504745.filter1,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,2,2,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上（表侧表示）或墓地的2张卡片作为效果对象
	local g2=Duel.SelectTarget(tp,c58504745.filter2,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 设置操作信息：将选中的4张卡送回持有者卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,4,0,0)
end
-- 过滤函数3：筛选出在效果处理时仍与效果相关的卡片
function c58504745.filter3(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRelateToEffect(e)
end
-- 效果处理函数：将选中的卡片送回持有者卡组并洗牌
function c58504745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象且依然有效的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c58504745.filter3,nil,e)
	-- 将目标卡片送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
