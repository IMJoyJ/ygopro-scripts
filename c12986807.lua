--ラヴァル・グレイター
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- 这张卡同调召唤成功时，自己把1张手卡送去墓地。这张卡被卡的效果破坏的场合，可以作为代替把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外。
function c12986807.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上炎属性的调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，自己把1张手卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12986807,0))  --"把1张手卡送去墓地"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c12986807.condition)
	e1:SetTarget(c12986807.target)
	e1:SetOperation(c12986807.operation)
	c:RegisterEffect(e1)
	-- 这张卡被卡的效果破坏的场合，可以作为代替把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c12986807.desreptg)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为同调召唤成功
function c12986807.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果处理时要送去墓地的卡组信息
function c12986807.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要处理1张手卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 执行将手卡送去墓地的效果处理
function c12986807.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择1张手卡作为送去墓地的目标
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 定义用于筛选墓地中的「熔岩」怪兽的过滤函数
function c12986807.repfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 定义破坏代替效果的处理函数
function c12986807.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		-- 检查场上是否存在满足条件的「熔岩」怪兽可以除外
		and Duel.IsExistingMatchingCard(c12986807.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动此效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		-- 从墓地中选择1只「熔岩」怪兽作为除外对象
		local g=Duel.SelectMatchingCard(tp,c12986807.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的卡从游戏中除外
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		return true
	else return false end
end
