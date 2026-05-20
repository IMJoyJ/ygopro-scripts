--コアラッコアラ
-- 效果：
-- 「树熊海獭」＋「海獭树熊」
-- 从手卡把1只兽族怪兽送去墓地，选择对方场上存在的1只怪兽发动。选择的怪兽破坏。
function c7243511.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为「树熊海獭」和「海獭树熊」
	aux.AddFusionProcCode2(c,87685879,71759912,true,true)
	-- 从手卡把1只兽族怪兽送去墓地，选择对方场上存在的1只怪兽发动。选择的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7243511,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c7243511.cost)
	e1:SetTarget(c7243511.target)
	e1:SetOperation(c7243511.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中可作为代价送去墓地的兽族怪兽
function c7243511.cfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：从手卡将1只兽族怪兽送去墓地
function c7243511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为代价送去墓地的兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7243511.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手卡中1只满足条件的兽族怪兽
	local cg=Duel.SelectMatchingCard(tp,c7243511.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(cg,REASON_COST)
end
-- 靶向/目标选择函数：选择对方场上的1只怪兽作为效果对象
function c7243511.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可作为对象选择的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：破坏选择的对方怪兽
function c7243511.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
