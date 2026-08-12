--超信地旋回
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只攻击表示的机械族·地属性超量怪兽和对方场上1只怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽破坏。
-- ●以自己场上1只守备表示的机械族·地属性超量怪兽和对方场上1张魔法·陷阱卡为对象才能发动。那只自己怪兽的表示形式变更，那张对方的魔法·陷阱卡破坏。
function c22866836.initial_effect(c)
	-- 以自己场上1只攻击表示的机械族·地属性超量怪兽和对方场上1只怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22866836,0))  --"破坏对方怪兽"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c22866836.target1)
	e1:SetOperation(c22866836.operation1)
	c:RegisterEffect(e1)
	-- 以自己场上1只守备表示的机械族·地属性超量怪兽和对方场上1张魔法·陷阱卡为对象才能发动。那只自己怪兽的表示形式变更，那张对方的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22866836,1))  --"破坏对方魔陷"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetTarget(c22866836.target2)
	e2:SetOperation(c22866836.operation2)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的攻击表示的机械族·地属性超量怪兽作为效果对象
function c22866836.tgfilter1(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsType(TYPE_XYZ) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 判断是否满足效果发动条件
function c22866836.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		-- 判断自己场上是否存在满足条件的攻击表示的机械族·地属性超量怪兽
		and Duel.IsExistingTarget(c22866836.tgfilter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的攻击表示的机械族·地属性超量怪兽作为对象
	local pg=Duel.SelectTarget(tp,c22866836.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的怪兽作为对象
	local dg=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,pg,1,0,0)
	-- 设置操作信息：破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 处理效果的执行逻辑
function c22866836.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取操作信息中的表示形式改变对象
	local ex1,pg=Duel.GetOperationInfo(0,CATEGORY_POSITION)
	-- 获取操作信息中的破坏对象
	local ex2,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local pc=pg:GetFirst()
	local dc=dg:GetFirst()
	if pc:IsRelateToEffect(e) and dc:IsRelateToEffect(e)
		and pc:IsControler(tp)
		-- 将对象怪兽变为表侧守备表示
		and Duel.ChangePosition(pc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and dc:IsControler(1-tp) then
		-- 破坏对象怪兽
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
-- 筛选满足条件的守备表示的机械族·地属性超量怪兽作为效果对象
function c22866836.tgfilter2(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsType(TYPE_XYZ) and c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 判断是否满足效果发动条件
function c22866836.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_SZONE,1,nil)
		-- 判断自己场上是否存在满足条件的守备表示的机械族·地属性超量怪兽
		and Duel.IsExistingTarget(c22866836.tgfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的守备表示的机械族·地属性超量怪兽作为对象
	local pg=Duel.SelectTarget(tp,c22866836.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的魔法·陷阱卡作为对象
	local dg=Duel.SelectTarget(tp,nil,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,pg,1,0,0)
	-- 设置操作信息：破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 处理效果的执行逻辑
function c22866836.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取操作信息中的表示形式改变对象
	local ex1,pg=Duel.GetOperationInfo(0,CATEGORY_POSITION)
	-- 获取操作信息中的破坏对象
	local ex2,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local pc=pg:GetFirst()
	local dc=dg:GetFirst()
	if pc:IsRelateToEffect(e) and dc:IsRelateToEffect(e)
		and pc:IsControler(tp)
		-- 将对象怪兽变为表侧守备表示
		and Duel.ChangePosition(pc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and dc:IsControler(1-tp) then
		-- 破坏对象魔法·陷阱卡
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
