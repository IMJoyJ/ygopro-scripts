--異種闘争
-- 效果：
-- 双方场上存在的怪兽全部表侧表示的场合才能发动。双方玩家直到各自属性变成1种类，把场上的自己怪兽送去墓地。
function c60530944.initial_effect(c)
	-- 双方场上存在的怪兽全部表侧表示的场合才能发动。双方玩家直到各自属性变成1种类，把场上的自己怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c60530944.condition)
	e1:SetOperation(c60530944.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：双方场上都有怪兽存在，且全部为表侧表示
function c60530944.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上是否存在里侧表示的怪兽（即要求全部表侧表示）
		and not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查对方场上是否存在里侧表示的怪兽（即要求全部表侧表示）
		and not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil)
end
-- 辅助函数：计算并返回传入怪兽组中所有怪兽的属性按位或（OR）组合值
function c60530944.getattr(g)
	local aat=0
	local tc=g:GetFirst()
	while tc do
		aat=bit.bor(aat,tc:GetAttribute())
		tc=g:GetNext()
	end
	return aat
end
-- 过滤函数：用于筛选出属性与指定属性相同的怪兽
function c60530944.rmfilter(c,at)
	return c:GetAttribute()==at
end
-- 效果处理：若在效果处理时双方场上不满足“都有怪兽且全部表侧表示”的条件，则不进行处理
function c60530944.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有怪兽
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 或者自己场上有里侧表示的怪兽
		or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
		-- 或者对方场上没有怪兽
		or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
		-- 或者对方场上有里侧表示的怪兽，则直接结束效果处理
		or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil) then return end
	-- 获取自己场上的所有怪兽
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取对方场上的所有怪兽
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local c=e:GetHandler()
	-- 提示自己选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让自己从自己场上怪兽已有的属性中宣言1个属性（作为保留的属性）
	local r1=Duel.AnnounceAttribute(tp,1,c60530944.getattr(g1))
	g1:Remove(c60530944.rmfilter,nil,r1)
	-- 提示对方选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让对方从对方场上怪兽已有的属性中宣言1个属性（作为保留的属性）
	local r2=Duel.AnnounceAttribute(1-tp,1,c60530944.getattr(g2))
	g2:Remove(c60530944.rmfilter,nil,r2)
	g1:Merge(g2)
	-- 将双方场上除宣言属性以外的所有怪兽因规则送去墓地
	Duel.SendtoGrave(g1,REASON_RULE)
end
