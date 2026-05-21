--ロスト・ブルー・ブレイカー
-- 效果：
-- 场上有这张卡以外的鱼族·海龙族·水族怪兽存在的场合把这张卡解放才能发动。选择场上1张魔法·陷阱卡破坏。
function c95231062.initial_effect(c)
	-- 场上有这张卡以外的鱼族·海龙族·水族怪兽存在的场合把这张卡解放才能发动。选择场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95231062,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c95231062.condition)
	e1:SetCost(c95231062.cost)
	e1:SetTarget(c95231062.target)
	e1:SetOperation(c95231062.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的鱼族、水族或海龙族怪兽
function c95231062.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
end
-- 发动条件：场上存在自身以外的鱼族、水族或海龙族怪兽
function c95231062.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只自身以外的表侧表示鱼族、水族或海龙族怪兽
	return Duel.IsExistingMatchingCard(c95231062.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 发动代价：解放自身
function c95231062.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：魔法或陷阱卡
function c95231062.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择场上1张魔法、陷阱卡为对象
function c95231062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c95231062.desfilter(chkc) end
	-- 检查场上是否存在可以作为对象的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c95231062.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c95231062.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏选中的魔法、陷阱卡
function c95231062.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
