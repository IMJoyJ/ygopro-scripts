--悪魔払い
-- 效果：
-- 场上的恶魔族怪兽全部破坏。
function c26725158.initial_effect(c)
	-- 场上的恶魔族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26725158.target)
	e1:SetOperation(c26725158.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否为表侧表示的恶魔族
function c26725158.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 效果发动时的处理函数，用于确认是否满足发动条件并设置破坏对象
function c26725158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26725158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足条件的恶魔族怪兽组成组
	local sg=Duel.GetMatchingGroup(c26725158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁处理信息，指定将要破坏的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果发动时的处理函数，执行破坏效果
function c26725158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的恶魔族怪兽组成组
	local sg=Duel.GetMatchingGroup(c26725158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将指定怪兽组以效果原因进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
