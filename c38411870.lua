--つり天井
-- 效果：
-- 全场上的怪兽4只以上存在的场合才能发动。表侧表示的怪兽全部破坏。
function c38411870.initial_effect(c)
	-- 效果定义：发动时点为自由时点，效果分类为破坏，条件为场上有4只以上怪兽，目标为场上的表侧表示怪兽，效果处理为破坏目标怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c38411870.condition)
	e1:SetTarget(c38411870.target)
	e1:SetOperation(c38411870.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：场上的怪兽4只以上存在
function c38411870.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上怪兽数量是否大于等于4
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>=4
end
-- 过滤函数：判断怪兽是否为表侧表示
function c38411870.filter(c)
	return c:IsFaceup()
end
-- 效果处理目标设定：检查是否存在表侧表示的怪兽，若存在则设置破坏对象为所有表侧表示怪兽
function c38411870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的怪兽（表侧表示）
	if chk==0 then return Duel.IsExistingMatchingCard(c38411870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取所有满足条件的怪兽（表侧表示）
	local sg=Duel.GetMatchingGroup(c38411870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：将要破坏的怪兽组和数量设定为处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理：对满足条件的怪兽进行破坏
function c38411870.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的怪兽（表侧表示）
	local sg=Duel.GetMatchingGroup(c38411870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 执行破坏效果：将怪兽破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
