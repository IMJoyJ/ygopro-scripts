--破滅の魔王ガーランドルフ
-- 效果：
-- 「破灭的仪式」降临。这张卡仪式召唤成功时，持有这张卡的攻击力以下的守备力的这张卡以外的场上表侧表示存在的怪兽全部破坏，破坏的怪兽每有1只这张卡的攻击力上升100。
function c30646525.initial_effect(c)
	-- 将「破灭的仪式」的卡片密码加入当前卡片的关联卡片列表中
	aux.AddCodeList(c,52913738)
	c:EnableReviveLimit()
	-- 这张卡仪式召唤成功时，持有这张卡的攻击力以下的守备力的这张卡以外的场上表侧表示存在的怪兽全部破坏，破坏的怪兽每有1只这张卡的攻击力上升100。
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
-- 过滤条件：判断此卡是否是以仪式召唤的方式特殊召唤成功
function c30646525.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤条件：筛选场上表侧表示且守备力在指定攻击力以下的怪兽
function c30646525.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- 效果目标阶段：获取场上所有符合条件的破坏目标，并设置效果处理的破坏操作信息
function c30646525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取双方场上除自身外，守备力在自身当前攻击力以下的表侧表示怪兽集合
	local g=Duel.GetMatchingGroup(c30646525.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	-- 设置效果处理时的破坏操作信息，包含要破坏的卡片集合以及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：破坏符合条件的场上怪兽，并在破坏成功时根据数量上升此卡的攻击力
function c30646525.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 获取效果处理时双方场上除自身外，守备力在自身当前攻击力以下的表侧表示怪兽集合
	local g=Duel.GetMatchingGroup(c30646525.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	-- 将符合条件的怪兽全部破坏，并记录实际被破坏的数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 破坏的怪兽每有1只这张卡的攻击力上升100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
