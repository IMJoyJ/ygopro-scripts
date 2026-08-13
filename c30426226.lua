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
-- 判定怪兽是否不能变更控制权；若返回真，说明该怪兽受到“不能改变控制权”效果影响，无法参与交换。
function c30426226.filter(c)
	return not c:IsAbleToChangeControler()
end
-- 发动条件检查：获取双方场上全部怪兽并分为己方组g1与对方组g2；要求g1非空、双方数量相等、所有怪兽均可变更控制权，且交换后双方场上均有足够怪兽区空格，满足上述条件才可发动。
function c30426226.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得双方场上（自己的怪兽区加对方的怪兽区）的所有怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local g1=g:Filter(Card.IsControler,nil,tp)
	local g2=g:Filter(Card.IsControler,nil,1-tp)
	if chk==0 then return g1:GetCount()>0 and g1:GetCount()==g2:GetCount()
		and g:FilterCount(c30426226.filter,nil)==0
		-- 检查在自己怪兽g1离开后，自己场上可用的怪兽区数量是否不少于对方怪兽g2的数量，以保证对方怪兽能全部转移到自己场上。
		and Duel.GetMZoneCount(tp,g1,tp,LOCATION_REASON_CONTROL)>=g2:GetCount()
		-- 检查在对方怪兽g2离开后，对方场上可用的怪兽区数量是否不少于己方怪兽g1的数量，以保证己方怪兽能全部转移到对方场上。
		and Duel.GetMZoneCount(1-tp,g2,1-tp,LOCATION_REASON_CONTROL)>=g1:GetCount() end
	-- 设置操作信息：声明本效果属于改变控制权，作用对象为当前场上所有怪兽，数量为怪兽总数，供系统进行相关连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：重新取得双方场上当前的怪兽，然后交换这些怪兽的控制权。
function c30426226.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动者（tp）当前场上的全部怪兽。
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 取得对方（1-tp）当前场上的全部怪兽。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 将己方怪兽组g1与对方怪兽组g2的控制权互换，即双方场上所有怪兽控制权全部交换。
	Duel.SwapControl(g1,g2)
end
