--シャインスピリッツ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的光属性怪兽以外的怪兽全部破坏。
function c12624008.initial_effect(c)
	-- 效果原文内容：这张卡被战斗破坏送去墓地时，场上表侧表示存在的光属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12624008,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c12624008.condition)
	e1:SetTarget(c12624008.target)
	e1:SetOperation(c12624008.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断触发效果的条件是否满足，即此卡是否因战斗破坏而进入墓地
function c12624008.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面作用：过滤函数，用于筛选场上的怪兽，条件为里侧表示或非光属性
function c12624008.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_LIGHT)
end
-- 规则层面作用：设置连锁处理的目标，确定要破坏的怪兽数量和对象
function c12624008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：获取满足条件的场上怪兽组，即非光属性且表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c12624008.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面作用：设置当前连锁的操作信息，包括破坏效果的处理对象和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面作用：定义效果发动后的处理函数，执行破坏操作
function c12624008.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：再次获取满足条件的场上怪兽组，准备进行破坏处理
	local g=Duel.GetMatchingGroup(c12624008.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面作用：将符合条件的怪兽全部破坏，破坏原因为效果
	Duel.Destroy(g,REASON_EFFECT)
end
