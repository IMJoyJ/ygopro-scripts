--獄落鳥
-- 效果：
-- ①：这张卡的攻击力·守备力上升自己墓地的调整数量×100。
-- ②：1回合1次，把手卡1只调整送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c84845628.initial_effect(c)
	-- ①：这张卡的攻击力·守备力上升自己墓地的调整数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c84845628.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把手卡1只调整送去墓地，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c84845628.cost)
	e3:SetTarget(c84845628.target)
	e3:SetOperation(c84845628.operation)
	c:RegisterEffect(e3)
end
-- 计算攻击力·守备力上升值的辅助函数
function c84845628.adval(e,c)
	local tp=c:GetControler()
	-- 返回自己墓地的调整怪兽数量乘以100的数值
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_TUNER)*100
end
-- 过滤手牌中可以作为代价送去墓地的调整怪兽
function c84845628.cfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价处理函数
function c84845628.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只可以作为代价送去墓地的调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84845628.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择手牌中1只调整怪兽作为代价送去墓地
	Duel.DiscardHand(tp,c84845628.cfilter,1,1,REASON_COST,nil)
end
-- 效果发动时的目标选择与合法性检测函数
function c84845628.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查对方场上是否存在可以改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 玩家选择对方场上1只可以改变控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为改变1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理的执行函数
function c84845628.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 得到目标怪兽的控制权，直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
