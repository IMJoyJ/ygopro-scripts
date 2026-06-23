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
-- 过滤场上表侧表示且原本攻击力为0或原本守备力为0的怪兽的条件函数
function c10389794.filter(c)
	return c:IsFaceup() and (c:GetBaseAttack()==0 or (c:GetBaseDefense()==0 and c:IsDefenseAbove(0)))
end
-- 效果发动的常规检查，并设置破坏所有符合条件怪兽的操作信息
function c10389794.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上双方怪兽区域所有原本攻击力或原本守备力为0的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c10389794.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为破坏上述符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，获取并破坏场上原本攻击力或原本守备力为0的表侧表示怪兽
function c10389794.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上双方怪兽区域所有原本攻击力或原本守备力为0的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c10389794.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将上述符合条件的怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
