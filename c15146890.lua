--竜脈の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，另一边的自己的灵摆区域有「魔术师」卡存在的场合，把手卡1只灵摆怪兽丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽描述】
-- 优点只有精力充沛的新手少年魔术师。其实有着无意识间觉察到大地长眠的龙魂这种能力，虽然还是半吊子但其资质之高就连师父「龙穴之魔术师」也自认不如。
function c15146890.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，注册灵摆召唤与灵摆卡发动相关的基础效果。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，另一边的自己的灵摆区域有「魔术师」卡存在的场合，把手卡1只灵摆怪兽丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15146890,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c15146890.condition)
	e2:SetCost(c15146890.cost)
	e2:SetTarget(c15146890.target)
	e2:SetOperation(c15146890.operation)
	c:RegisterEffect(e2)
end
-- 发动条件判定：自己的另一侧灵摆区域存在「魔术师」字段的卡。
function c15146890.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在除自身以外的1张属于「魔术师」字段的卡（即另一侧灵摆区的「魔术师」卡）。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x98)
end
-- 代价筛选函数：手卡中的灵摆怪兽且可以被丢弃。
function c15146890.cfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
-- 发动代价处理：判定并执行从手卡丢弃1只灵摆怪兽。
function c15146890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查手卡是否存在至少1只满足条件的可丢弃灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15146890.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡选择并丢弃1只满足条件的灵摆怪兽，丢弃原因记为代价和丢弃。
	Duel.DiscardHand(tp,c15146890.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标筛选函数：场上的表侧表示怪兽。
function c15146890.filter(c)
	return c:IsFaceup()
end
-- 目标选择函数：以场上1只表侧表示怪兽为对象，并设置对应的破坏操作信息。
function c15146890.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15146890.filter(chkc) end
	-- 发动时检查场上是否存在1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c15146890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择破坏对象的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只表侧表示怪兽作为对象（同时将所选卡登记为连锁对象）。
	local g=Duel.SelectTarget(tp,c15146890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：确定破坏1张对象卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将选择的对象怪兽破坏。
function c15146890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁处理时的对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
