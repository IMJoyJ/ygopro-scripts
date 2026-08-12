--宝玉の祈り
-- 效果：
-- 把自己的魔法与陷阱卡区域存在的1张名字带有「宝玉兽」的卡送去墓地才能发动。对方场上1张卡破坏。
function c96331676.initial_effect(c)
	-- 把自己的魔法与陷阱卡区域存在的1张名字带有「宝玉兽」的卡送去墓地才能发动。对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c96331676.cost)
	e1:SetTarget(c96331676.target)
	e1:SetOperation(c96331676.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己魔法与陷阱卡区域表侧表示的「宝玉兽」卡片，且能作为代价送去墓地
function c96331676.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToGraveAsCost()
end
-- 发动代价：将自己魔法与陷阱卡区域存在的1张名字带有「宝玉兽」的卡送去墓地
function c96331676.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱卡区域是否存在至少1张满足条件的「宝玉兽」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c96331676.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己魔法与陷阱卡区域存在的1张表侧表示的「宝玉兽」卡片
	local g=Duel.SelectMatchingCard(tp,c96331676.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标：选择对方场上1张卡为对象，并设置破坏的操作信息
function c96331676.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：包含破坏分类，数量为1，目标为选择的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的卡
function c96331676.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
