--真青眼の究極竜
-- 效果：
-- 「青眼白龙」＋「青眼白龙」＋「青眼白龙」
-- 这个卡名的①的效果1回合可以使用最多2次。
-- ①：融合召唤的这张卡攻击的伤害步骤结束时，自己场上没有其他的表侧表示卡存在的场合，从额外卡组把1只「青眼」融合怪兽送去墓地才能发动。这张卡可以继续攻击。
-- ②：自己场上的「青眼」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。
function c56532353.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册以3张「青眼白龙」为素材的融合召唤手续
	aux.AddFusionProcCodeRep(c,89631139,3,true,true)
	-- ①：融合召唤的这张卡攻击的伤害步骤结束时，自己场上没有其他的表侧表示卡存在的场合，从额外卡组把1只「青眼」融合怪兽送去墓地才能发动。这张卡可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCountLimit(2,56532353)
	e1:SetCondition(c56532353.atcon)
	e1:SetCost(c56532353.atcost)
	e1:SetOperation(c56532353.atop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「青眼」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c56532353.condition)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c56532353.target)
	e2:SetOperation(c56532353.operation)
	c:RegisterEffect(e2)
end
-- 过滤额外卡组的「青眼」融合怪兽
function c56532353.costfilter(c)
	return c:IsSetCard(0xdd) and c:IsType(TYPE_FUSION) and c:IsAbleToGraveAsCost()
end
-- 检查是否满足攻击后继续攻击的效果发动条件
function c56532353.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
		-- 检查当前攻击怪兽是否是自身，且自身可以继续攻击
		and Duel.GetAttacker()==c and c:IsChainAttackable(0)
		-- 检查自己场上是否存在除自身以外的其他表侧表示卡片
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,c)
end
-- 执行从额外卡组将1只「青眼」融合怪兽送去墓地的代价
function c56532353.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以送去墓地的「青眼」融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56532353.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从额外卡组选择1只「青眼」融合怪兽
	local g=Duel.SelectMatchingCard(tp,c56532353.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 执行继续攻击的效果处理
function c56532353.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使这张卡可以继续进行1次攻击
	Duel.ChainAttack()
end
-- 过滤自己场上表侧表示的「青眼」怪兽
function c56532353.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0xdd)
end
-- 检查发动效果的对象是否为自己场上的「青眼」怪兽，且该发动是否可以被无效
function c56532353.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁效果的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c56532353.filter,1,nil,tp)
		-- 检查该连锁的发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 检查并设置无效发动与破坏的操作信息
function c56532353.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将该效果发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效发动并破坏的效果处理
function c56532353.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该效果的发动，且该卡在场上与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
