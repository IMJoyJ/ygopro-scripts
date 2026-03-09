--DDD死偉王ヘル・アーマゲドン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
-- 【怪兽效果】
-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的原本攻击力数值。这个效果发动的回合，这张卡不能直接攻击。
-- ②：这张卡不会被不以这张卡为对象的魔法·陷阱卡的效果破坏。
function c47198668.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，允许灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c47198668.atktg1)
	e2:SetOperation(c47198668.atkop1)
	c:RegisterEffect(e2)
	-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的原本攻击力数值。这个效果发动的回合，这张卡不能直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1)
	e3:SetCost(c47198668.atkcost)
	e3:SetTarget(c47198668.atktg2)
	e3:SetOperation(c47198668.atkop2)
	c:RegisterEffect(e3)
	-- ②：这张卡不会被不以这张卡为对象的魔法·陷阱卡的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c47198668.efilter)
	c:RegisterEffect(e4)
end
-- 判断目标是否为表侧表示的「DD」怪兽
function c47198668.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 设置选择目标的条件，确保选择的是自己场上的表侧表示的「DD」怪兽
function c47198668.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47198668.filter1(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c47198668.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的1只怪兽作为对象
	Duel.SelectTarget(tp,c47198668.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果发动后的操作，将目标怪兽攻击力提升800
function c47198668.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将攻击力提升800的效果注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断被破坏的怪兽是否为战斗或效果破坏，并且在自己场上被破坏过
function c47198668.filter2(c,e,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
end
-- 设置发动效果时的费用，防止直接攻击
function c47198668.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsDirectAttacked() end
	-- 设置不能直接攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 设置选择目标的条件，确保选择的是被破坏的怪兽
function c47198668.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c47198668.filter2(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c47198668.filter2,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c47198668.filter2,1,1,nil,e,tp)
	-- 将选中的怪兽设为连锁对象
	Duel.SetTargetCard(g)
end
-- 处理效果发动后的操作，使自身攻击力提升被破坏怪兽的原本攻击力数值
function c47198668.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将攻击力提升的效果注册到自身上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断是否为魔法或陷阱卡的效果，并且该效果是否以自身为目标
function c47198668.efilter(e,re,rp)
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁中被指定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
