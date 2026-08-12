--ヘルプロミネンス
-- 效果：
-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的炎属性怪兽以外的怪兽全部破坏。
function c13846680.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，场上表侧表示存在的炎属性怪兽以外的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13846680,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c13846680.condition)
	e1:SetTarget(c13846680.target)
	e1:SetOperation(c13846680.operation)
	c:RegisterEffect(e1)
end
-- 检查触发条件：这张卡是否在墓地且被战斗破坏
function c13846680.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：判断怪兽是否为里侧表示或不是炎属性
function c13846680.filter(c)
	return (c:IsFacedown() or c:GetAttribute()~=ATTRIBUTE_FIRE)
end
-- 设置连锁处理目标：将场上符合条件的怪兽作为破坏目标
function c13846680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取满足条件的怪兽数组：筛选出非炎属性且表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c13846680.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：确定本次连锁将要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：执行破坏效果
function c13846680.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽数组：筛选出非炎属性且表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c13846680.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将符合条件的怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
