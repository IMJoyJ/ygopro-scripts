--スウィッチヒーロー
-- 效果：
-- ①：双方场上的怪兽数量相同的场合，那些怪兽的控制权全部交换。
function c30426226.initial_effect(c)
	-- ①：双方场上的怪兽数量相同的场合，那些怪兽的控制权全部交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c30426226.target)
	e1:SetOperation(c30426226.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否无法改变控制权
function c30426226.filter(c)
	return not c:IsAbleToChangeControler()
end
-- 效果的发动条件判断，检查双方场上怪兽数量是否相等且满足控制权交换条件
function c30426226.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local g1=g:Filter(Card.IsControler,nil,tp)
	local g2=g:Filter(Card.IsControler,nil,1-tp)
	if chk==0 then return g1:GetCount()>0 and g1:GetCount()==g2:GetCount()
		and g:FilterCount(c30426226.filter,nil)==0
		-- 检查自己场上的怪兽是否有足够的怪兽区来接收对方场上的怪兽
		and Duel.GetMZoneCount(tp,g1,tp,LOCATION_REASON_CONTROL)>=g2:GetCount()
		-- 检查对方场上的怪兽是否有足够的怪兽区来接收自己场上的怪兽
		and Duel.GetMZoneCount(1-tp,g2,1-tp,LOCATION_REASON_CONTROL)>=g1:GetCount() end
	-- 设置效果处理时需要交换控制权的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果发动时执行的操作，交换双方场上的所有怪兽控制权
function c30426226.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取对方场上的所有怪兽
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 执行怪兽控制权交换操作
	Duel.SwapControl(g1,g2)
end
