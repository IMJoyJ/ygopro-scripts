--放浪の勇者 フリード
-- 效果：
-- 可以把自己墓地存在的2只光属性怪兽从游戏中除外，选择持有比场上表侧表示存在的这张卡的攻击力高的攻击力的场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
function c16556849.initial_effect(c)
	-- 可以把自己墓地存在的2只光属性怪兽从游戏中除外，选择持有比场上表侧表示存在的这张卡的攻击力高的攻击力的场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16556849,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16556849.cost)
	e1:SetTarget(c16556849.tg)
	e1:SetOperation(c16556849.op)
	c:RegisterEffect(e1)
end
-- 定义效果的发动代价：从自己墓地选择2只光属性怪兽除外作为发动COST。
function c16556849.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价合法性检测：确认自己墓地是否存在至少2只可作为代价除外的光属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c16556849.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出提示消息，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择2张满足条件的光属性怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c16556849.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张光属性怪兽以表侧表示除外，作为发动COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 代价过滤器：卡必须为光属性且可以作为代价除外。
function c16556849.costfilter(co)
	return co:IsAttribute(ATTRIBUTE_LIGHT) and co:IsAbleToRemoveAsCost()
end
-- 对象过滤器：表侧表示且当前攻击力高于这张卡的攻击力。
function c16556849.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 定义效果的发动对象：选择场上表侧表示存在且攻击力高于这张卡的1只怪兽为破坏对象。
function c16556849.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16556849.filter(chkc,e:GetHandler():GetAttack()) end
	-- 目标合法性检测：确认场上是否存在表侧表示且攻击力高于这张卡的怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c16556849.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 弹出提示消息，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的1只表侧表示怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c16556849.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	-- 登记操作信息：本次效果将破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：在这张卡仍在场上表侧表示、对象仍关联且表侧表示、且对象攻击力仍高于这张卡的条件下，将对象怪兽破坏。
function c16556849.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:GetAttack()>c:GetAttack() then
		-- 以效果破坏对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
