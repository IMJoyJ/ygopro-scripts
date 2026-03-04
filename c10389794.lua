--デス・ドーナツ
-- 效果：
-- 反转：场上表侧表示存在的原本攻击力或者原本守备力是0的怪兽全部破坏。
function c10389794.initial_effect(c)
	-- 反转：场上表侧表示存在的原本攻击力或者原本守备力是0的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10389794,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c10389794.target)
	e1:SetOperation(c10389794.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否满足条件（表侧表示且原本攻击力或原本守备力为0）
function c10389794.filter(c)
	return c:IsFaceup() and (c:GetBaseAttack()==0 or (c:GetBaseDefense()==0 and c:IsDefenseAbove(0)))
end
-- 效果处理时的Target函数，用于确定破坏对象
function c10389794.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取满足条件的怪兽数组（场上的表侧表示且原本攻击力或原本守备力为0）
	local g=Duel.GetMatchingGroup(c10389794.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前处理的连锁的操作信息，指定将要破坏的怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的Operation函数，执行破坏效果
function c10389794.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽数组（场上的表侧表示且原本攻击力或原本守备力为0）
	local g=Duel.GetMatchingGroup(c10389794.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将满足条件的怪兽全部破坏，破坏原因为效果
	Duel.Destroy(g,REASON_EFFECT)
end
