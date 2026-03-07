--妨害電波
-- 效果：
-- 双方场上存在的同调怪兽全部变成守备表示，结束阶段时场上表侧表示存在的同调怪兽全部回到额外卡组。
function c39440937.initial_effect(c)
	-- 卡片效果：双方场上存在的同调怪兽全部变成守备表示，结束阶段时场上表侧表示存在的同调怪兽全部回到额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39440937.target)
	e1:SetOperation(c39440937.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在表侧攻击表示的同调怪兽且可以改变表示形式。
function c39440937.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_SYNCHRO) and c:IsCanChangePosition()
end
-- 效果发动时的处理函数：检查场上是否存在满足条件的同调怪兽，若存在则设置操作信息为改变表示形式。
function c39440937.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查场上是否存在至少一张满足条件的同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c39440937.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的同调怪兽组：从双方场上获取所有表侧攻击表示的同调怪兽。
	local g=Duel.GetMatchingGroup(c39440937.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：将要改变表示形式的怪兽组和数量设置为操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果发动时的处理函数：获取场上所有满足条件的同调怪兽并将其变为守备表示，若成功则注册结束阶段效果。
function c39440937.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的同调怪兽组：从双方场上获取所有表侧攻击表示的同调怪兽。
	local g=Duel.GetMatchingGroup(c39440937.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 条件判断：若场上存在满足条件的怪兽且改变表示形式成功，则注册结束阶段效果。
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEUP_DEFENSE)~=0 then
		-- 注册结束阶段效果：在结束阶段时触发，用于将符合条件的同调怪兽送回额外卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(c39440937.tdcon)
		e1:SetOperation(c39440937.tdop)
		-- 注册效果：将结束阶段效果注册到玩家全局环境中。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤函数：检查场上是否存在表侧表示的同调怪兽且可以送回额外卡组。
function c39440937.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 结束阶段效果的触发条件：检查场上是否存在满足条件的同调怪兽。
function c39440937.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：检查场上是否存在至少一张满足条件的同调怪兽。
	return Duel.IsExistingMatchingCard(c39440937.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 结束阶段效果的处理函数：将场上所有满足条件的同调怪兽送回额外卡组。
function c39440937.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的同调怪兽组：从双方场上获取所有表侧表示的同调怪兽。
	local g=Duel.GetMatchingGroup(c39440937.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将怪兽送回额外卡组：以效果原因将怪兽送回卡组顶端。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
end
