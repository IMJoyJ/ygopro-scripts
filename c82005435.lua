--女忍者ヤエ
-- 效果：
-- 从手卡将1张风属性怪兽卡弃到墓地。将对方场上存在的所有魔法·陷阱卡全部弹回其持有者手卡。
function c82005435.initial_effect(c)
	-- 从手卡将1张风属性怪兽卡弃到墓地。将对方场上存在的所有魔法·陷阱卡全部弹回其持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82005435,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c82005435.cost)
	e1:SetTarget(c82005435.target)
	e1:SetOperation(c82005435.operation)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可作为代价丢弃的风属性怪兽卡
function c82005435.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价处理函数
function c82005435.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可作为代价丢弃的风属性怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82005435.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手牌选择1张满足过滤条件（风属性且可丢弃）的卡
	local cg=Duel.SelectMatchingCard(tp,c82005435.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡作为代价丢弃送去墓地
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
end
-- 过滤对方场上可以返回手牌的魔法、陷阱卡
function c82005435.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动的目标确认与操作信息设置函数
function c82005435.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以返回手牌的魔法、陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82005435.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以返回手牌的魔法、陷阱卡组
	local sg=Duel.GetMatchingGroup(c82005435.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息为将对方场上的魔法、陷阱卡全部返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理的执行函数
function c82005435.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有的魔法、陷阱卡组
	local sg=Duel.GetMatchingGroup(c82005435.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的魔法、陷阱卡全部送回持有者的手卡
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
