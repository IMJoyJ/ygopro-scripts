--借カラクリ整備蔵
-- 效果：
-- 自己场上有名字带有「机巧」的怪兽表侧守备表示存在的场合才能发动。对方发动的魔法·陷阱卡的发动无效并破坏。
function c2924048.initial_effect(c)
	-- 自己场上有名字带有「机巧」的怪兽表侧守备表示存在的场合才能发动。对方发动的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2924048.condition)
	e1:SetTarget(c2924048.target)
	e1:SetOperation(c2924048.activate)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于筛选自己场上表侧守备表示且拥有「机巧」字段的怪兽，作为效果发动条件的判定依据。
function c2924048.cfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x11)
end
-- 该函数是效果的发动条件判定：在对方发动魔法·陷阱卡时，若自己场上存在表侧守备表示的「机巧」怪兽，且该连锁可以被无效，则本卡可以发动；否则不能发动。
function c2924048.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 如果连锁的发动者是己方，或自己场上不存在表侧守备表示的「机巧」怪兽，则不满足发动条件，直接返回 false。
	if ep==tp or not Duel.IsExistingMatchingCard(c2924048.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 进一步确认对方发动的连锁是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该发动能够被无效，两者同时满足才允许发动。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 该函数是效果发动时的处理准备：没有取对象操作，仅向系统登记本次处理包含“无效发动”和“破坏”的信息，并允许效果发动。
function c2924048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，声明本次效果处理包含“使发动无效”的分类，处理对象为对方发动的那张魔法·陷阱卡所在的连锁组 eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 当对方发动的卡可被破坏且仍与本次效果关联时，追加设置操作信息，声明本次处理还包含“破坏”分类，目标同样是对方发动的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 该函数是效果处理时的实际操作：先无效对方发动的魔法·陷阱卡的发动，若无效成功且对方那张卡仍与效果关联，则将其破坏。
function c2924048.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 只有当对方那张卡的发动被成功无效，且该卡仍然与本次效果存在关联时，才继续执行破坏处理，防止发动无效失败或卡已离场时误破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将对方发动的那张魔法·陷阱卡破坏，使其从场上送去墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
