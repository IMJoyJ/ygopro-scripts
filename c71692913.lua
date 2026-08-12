--相克の魔術師
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以自己场上1只超量怪兽为对象才能发动。这个回合那只超量怪兽可以作为和那个阶级相同数值的等级的怪兽来成为超量召唤的素材。
-- 【怪兽效果】
-- ①：1回合1次，以场上1只光属性怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c71692913.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只超量怪兽为对象才能发动。这个回合那只超量怪兽可以作为和那个阶级相同数值的等级的怪兽来成为超量召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c71692913.xyztg)
	e2:SetOperation(c71692913.xyzop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以场上1只光属性怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c71692913.distg)
	e3:SetOperation(c71692913.disop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的超量怪兽
function c71692913.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 灵摆效果的对象选择与发动条件判定函数
function c71692913.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c71692913.xyzfilter(chkc) end
	-- 判定自己场上是否存在可以作为效果对象的表侧表示超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c71692913.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c71692913.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果的执行函数
function c71692913.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合那只超量怪兽可以作为和那个阶级相同数值的等级的怪兽来成为超量召唤的素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_LEVEL)
		e1:SetValue(c71692913.xyzlv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 返回该怪兽的阶级数值，作为其在超量召唤时可替代的等级数值
function c71692913.xyzlv(e,c,rc)
	return c:GetRank()
end
-- 过滤场上可以被无效效果的光属性怪兽
function c71692913.disfilter(c)
	-- 判定卡片是否为光属性且属于未被无效化的表侧表示效果怪兽
	return c:IsAttribute(ATTRIBUTE_LIGHT) and aux.NegateEffectMonsterFilter(c)
end
-- 怪兽效果的对象选择与发动条件判定函数
function c71692913.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c71692913.disfilter(chkc) end
	-- 判定场上是否存在可以作为效果对象的光属性效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c71692913.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只表侧表示的光属性效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c71692913.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表明此效果包含“无效效果”的操作，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 怪兽效果的执行函数
function c71692913.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的光属性怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
