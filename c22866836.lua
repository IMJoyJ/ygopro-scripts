--超信地旋回
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只攻击表示的机械族·地属性超量怪兽和对方场上1只怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽破坏。
-- ●以自己场上1只守备表示的机械族·地属性超量怪兽和对方场上1张魔法·陷阱卡为对象才能发动。那只自己怪兽的表示形式变更，那张对方的魔法·陷阱卡破坏。
function c22866836.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●以自己场上1只攻击表示的机械族·地属性超量怪兽和对方场上1只怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽破坏。
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
	-- ●以自己场上1只守备表示的机械族·地属性超量怪兽和对方场上1张魔法·陷阱卡为对象才能发动。那只自己怪兽的表示形式变更，那张对方的魔法·陷阱卡破坏。
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
-- 第一个效果的选择对象过滤器：判定怪兽为机械族·地属性·超量怪兽、表侧攻击表示且可以改变表示形式。
function c22866836.tgfilter1(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsType(TYPE_XYZ) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 第一个效果的发动条件判断与选对象：发动时检查自己场上存在符合条件的攻击表示机械族·地属性超量怪兽，且对方场上有怪兽；满足后进入选择对象阶段。
function c22866836.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动合法性检查：确认对方场上是否存在至少1只怪兽可以作为取对象的目标。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		-- 同时确认自己场上是否存在至少1只满足tgfilter1条件的攻击表示机械族·地属性超量怪兽，作为可变更表示形式的对象。
		and Duel.IsExistingTarget(c22866836.tgfilter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家发送“选择要改变表示形式的怪兽”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只符合条件的攻击表示机械族·地属性超量怪兽作为效果对象。
	local pg=Duel.SelectTarget(tp,c22866836.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向操作玩家发送“选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为破坏对象（过滤条件为nil，即任意怪兽）。
	local dg=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将变更表示形式的操作信息登记为所选的pg（表示形式变更）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,pg,1,0,0)
	-- 将破坏的操作信息登记为所选的dg（破坏）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 第一个效果的解决处理：取出变更表示形式和破坏的对象；若自己怪兽仍与效果相关且成功变更表示形式、对方怪兽仍与效果相关且由对方控制，则将其破坏。
function c22866836.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 从操作信息中取出之前登记的要变更表示形式的对象组pg。
	local ex1,pg=Duel.GetOperationInfo(0,CATEGORY_POSITION)
	-- 从操作信息中取出之前登记的要破坏的对象组dg。
	local ex2,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local pc=pg:GetFirst()
	local dc=dg:GetFirst()
	if pc:IsRelateToEffect(e) and dc:IsRelateToEffect(e)
		and pc:IsControler(tp)
		-- 尝试变更自己怪兽的表示形式（从表侧攻击表示变为表侧守备表示），返回值非0表示变更成功。
		and Duel.ChangePosition(pc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and dc:IsControler(1-tp) then
		-- 以效果破坏对方怪兽dc。
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
-- 第二个效果的选择对象过滤器：判定怪兽为机械族·地属性·超量怪兽、表侧守备表示且可以改变表示形式。
function c22866836.tgfilter2(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsType(TYPE_XYZ) and c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 第二个效果的发动条件判断与选对象：发动时检查自己场上存在符合条件的守备表示机械族·地属性超量怪兽，且对方场上有魔法·陷阱卡；满足后进入选择对象阶段。
function c22866836.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动合法性检查：确认对方场上是否存在至少1张魔法·陷阱卡可以作为取对象的目标。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_SZONE,1,nil)
		-- 同时确认自己场上是否存在至少1只满足tgfilter2条件的守备表示机械族·地属性超量怪兽，作为可变更表示形式的对象。
		and Duel.IsExistingTarget(c22866836.tgfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家发送“选择要改变表示形式的怪兽”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只符合条件的守备表示机械族·地属性超量怪兽作为效果对象。
	local pg=Duel.SelectTarget(tp,c22866836.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向操作玩家发送“选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为破坏对象。
	local dg=Duel.SelectTarget(tp,nil,tp,0,LOCATION_SZONE,1,1,nil)
	-- 将变更表示形式的操作信息登记为所选的pg（表示形式变更）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,pg,1,0,0)
	-- 将破坏的操作信息登记为所选的dg（破坏）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 第二个效果的解决处理：取出变更表示形式和破坏的对象；若自己怪兽仍与效果相关且成功变更表示形式、对方魔陷仍与效果相关且由对方控制，则将其破坏。
function c22866836.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 从操作信息中取出之前登记的要变更表示形式的对象组pg。
	local ex1,pg=Duel.GetOperationInfo(0,CATEGORY_POSITION)
	-- 从操作信息中取出之前登记的要破坏的对象组dg。
	local ex2,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local pc=pg:GetFirst()
	local dc=dg:GetFirst()
	if pc:IsRelateToEffect(e) and dc:IsRelateToEffect(e)
		and pc:IsControler(tp)
		-- 尝试变更自己怪兽的表示形式（从表侧守备表示变为表侧攻击表示），返回值非0表示变更成功。
		and Duel.ChangePosition(pc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and dc:IsControler(1-tp) then
		-- 以效果破坏对方魔法·陷阱卡dc。
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
