--魔轟神ガルバス
-- 效果：
-- 把1张手卡丢弃去墓地发动。持有这张卡的攻击力以下的守备力的对方场上表侧表示存在的1只怪兽破坏。
function c60434101.initial_effect(c)
	-- 把1张手卡丢弃去墓地发动。持有这张卡的攻击力以下的守备力的对方场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60434101,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c60434101.cost)
	e1:SetTarget(c60434101.tg)
	e1:SetOperation(c60434101.op)
	c:RegisterEffect(e1)
end
-- 过滤可以作为代价丢弃去墓地的手牌
function c60434101.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价处理函数
function c60434101.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以作为代价丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c60434101.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,c60434101.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 过滤对方场上表侧表示且守备力在指定数值以下的怪兽
function c60434101.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- 效果的目标选择与发动准备函数
function c60434101.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c60434101.filter(chkc,c:GetAttack()) end
	-- 检查对方场上是否存在至少1只表侧表示且守备力在自身攻击力以下的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c60434101.filter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示且守备力在自身攻击力以下的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60434101.filter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack())
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的实际处理函数
function c60434101.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsDefenseBelow(c:GetAttack()) then
		-- 因效果破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
