--ふるい落とし
-- 效果：
-- 支付500基本分。场上表侧攻击表示存在的全部3星的怪兽破坏。
function c28604635.initial_effect(c)
	-- 支付500基本分。场上表侧攻击表示存在的全部3星的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28604635.cost)
	e1:SetTarget(c28604635.target)
	e1:SetOperation(c28604635.activate)
	c:RegisterEffect(e1)
end
-- 定义该效果的发动代价：支付500基本分，包含合法性检查和实际支付两部分。
function c28604635.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查阶段（chk==0），判断玩家是否能够支付500基本分，若不能则发动不合法。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际扣除玩家tp的500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 定义本效果要破坏的怪兽的筛选条件：表侧攻击表示且等级为3。
function c28604635.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevel(3)
end
-- 定义效果发动时的目标选择/登记阶段：确认场上存在符合条件的怪兽，并登记将破坏那些怪兽的操作信息。
function c28604635.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查阶段确认场上是否有至少1只表侧攻击表示且等级为3的怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28604635.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得场上全部满足筛选条件的怪兽（不取对象，处理时确定），用于登记破坏信息。
	local g=Duel.GetMatchingGroup(c28604635.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将本次效果要破坏的怪兽组及数量登记到连锁处理信息中，供其他卡的效果（如星尘龙等）进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时执行破坏：重新获取场上符合条件的怪兽，并将它们全部破坏。
function c28604635.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取得场上全部表侧攻击表示且等级为3的怪兽（因为效果处理时可能场况变化，需实时获取）。
	local g=Duel.GetMatchingGroup(c28604635.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将上述怪兽以效果破坏送入墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
