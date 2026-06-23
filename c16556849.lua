--放浪の勇者 フリード
-- 效果：
-- 可以把自己墓地存在的2只光属性怪兽从游戏中除外，选择持有比场上表侧表示存在的这张卡的攻击力高的攻击力的场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
function c16556849.initial_effect(c)
	-- 创建效果，设置效果描述为“破坏”，分类为破坏，属性为取对象，类型为起动效果，适用区域为主怪区，限制每回合使用1次，设置费用、目标和效果处理函数
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
-- 费用函数：检查是否满足条件的2张光属性怪兽存在于墓地，若满足则提示选择并除外这些卡
function c16556849.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件的2张光属性怪兽存在于墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c16556849.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c16556849.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 费用过滤函数：判断卡是否为光属性且可作为费用除外
function c16556849.costfilter(co)
	return co:IsAttribute(ATTRIBUTE_LIGHT) and co:IsAbleToRemoveAsCost()
end
-- 目标过滤函数：判断目标怪兽是否表侧表示且攻击力高于指定值
function c16556849.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 目标函数：检查是否存在满足条件的怪兽作为目标，若满足则提示选择并设置操作信息
function c16556849.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16556849.filter(chkc,e:GetHandler():GetAttack()) end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c16556849.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c16556849.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	-- 设置操作信息，指定破坏效果的目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：判断条件满足后破坏目标怪兽
function c16556849.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:GetAttack()>c:GetAttack() then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
