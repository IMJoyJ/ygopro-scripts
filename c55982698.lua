--A・O・J リバース・ブレイク
-- 效果：
-- 场上表侧表示光属性怪兽存在的场合，这张卡破坏。这张卡向里侧守备表示怪兽攻击的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
function c55982698.initial_effect(c)
	-- 这张卡向里侧守备表示怪兽攻击的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55982698,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c55982698.descon)
	e1:SetTarget(c55982698.destg)
	e1:SetOperation(c55982698.desop)
	c:RegisterEffect(e1)
	-- 场上表侧表示光属性怪兽存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c55982698.sdcon)
	c:RegisterEffect(e2)
end
-- 判断是否满足攻击里侧守备表示怪兽时发动破坏效果的条件
function c55982698.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 返回是否是自身进行攻击，且攻击目标存在、为里侧表示、为守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 破坏效果的发动准备，设置效果处理的分类和目标
function c55982698.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏操作信息，将攻击目标怪兽作为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 破坏效果的执行，将攻击目标怪兽破坏
function c55982698.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 因效果破坏该攻击目标怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示的光属性怪兽
function c55982698.sdfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 自我破坏效果的成立条件
function c55982698.sdcon(e)
	-- 检查双方场上是否存在至少1张表侧表示的光属性怪兽
	return Duel.IsExistingMatchingCard(c55982698.sdfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
