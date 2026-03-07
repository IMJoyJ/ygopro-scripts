--破滅の魔王ガーランドルフ
-- 效果：
-- 「破灭的仪式」降临。这张卡仪式召唤成功时，持有这张卡的攻击力以下的守备力的这张卡以外的场上表侧表示存在的怪兽全部破坏，破坏的怪兽每有1只这张卡的攻击力上升100。
function c30646525.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个诱发必发效果，用于处理仪式召唤成功时的破坏效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(30646525,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c30646525.condition)
	e1:SetTarget(c30646525.target)
	e1:SetOperation(c30646525.operation)
	c:RegisterEffect(e1)
end
-- 效果条件：这张卡通过仪式召唤方式特殊召唤成功
function c30646525.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数：判断目标怪兽是否为表侧表示且守备力小于等于指定攻击力
function c30646525.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- 效果目标：检索满足条件的场上怪兽并设置为破坏对象
function c30646525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 检索满足条件的场上怪兽组，条件为表侧表示且守备力不超过自身攻击力
	local g=Duel.GetMatchingGroup(c30646525.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	-- 设置连锁操作信息，指定将要破坏的怪兽组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏符合条件的怪兽，并根据破坏数量提升自身攻击力
function c30646525.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 再次检索满足条件的场上怪兽组，条件为表侧表示且守备力不超过自身攻击力
	local g=Duel.GetMatchingGroup(c30646525.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	-- 将满足条件的怪兽全部破坏，破坏原因为效果
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 效果原文内容：破坏的怪兽每有1只这张卡的攻击力上升100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
