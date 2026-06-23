--EMシール・イール
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功时，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。这个回合，那张卡不能发动。双方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
function c33833230.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33833230,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c33833230.distg)
	e1:SetOperation(c33833230.disop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功时，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。这个回合，那张卡不能发动。双方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33833230,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c33833230.lcktg)
	e2:SetOperation(c33833230.lckop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 设置灵摆效果的取对象目标选择函数，用于选择对方场上的表侧表示怪兽
function c33833230.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否为对方场上的表侧表示怪兽且符合被无效化条件
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 检查是否满足选择目标的条件，即对方场上是否存在可被无效的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将要使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理灵摆效果的发动后操作，使目标怪兽效果无效
function c33833230.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化（技能抽取）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 设置召唤/特殊召唤成功时的效果目标选择函数，用于选择对方场上的里侧表示魔法·陷阱卡
function c33833230.lcktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 检查是否满足选择目标的条件，即对方场上是否存在里侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方场上的1张里侧表示魔法·陷阱卡作为目标
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置连锁限制，允许所有效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- 处理召唤/特殊召唤成功时的效果发动后操作，使目标魔法·陷阱卡不能发动
function c33833230.lckop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 使目标魔法·陷阱卡不能发动
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
