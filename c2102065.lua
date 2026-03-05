--ブライニグル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只水属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。
-- ②：这张卡被送去墓地的场合，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
function c2102065.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只水属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2102065,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,2102065)
	e1:SetTarget(c2102065.atktg1)
	e1:SetOperation(c2102065.atkop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2102065,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,2102065)
	e3:SetTarget(c2102065.atktg2)
	e3:SetOperation(c2102065.atkop2)
	c:RegisterEffect(e3)
end
-- 检索满足条件的水属性且攻击力大于0的墓地怪兽
function c2102065.atkfilter1(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:GetAttack()>0
end
-- 选择满足条件的墓地水属性怪兽作为对象
function c2102065.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2102065.atkfilter1(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c2102065.atkfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地水属性怪兽作为对象
	Duel.SelectTarget(tp,c2102065.atkfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 将自身攻击力提升为选择的墓地水属性怪兽的攻击力数值
function c2102065.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个攻击力提升效果，提升值为对象怪兽的攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索满足条件的场上表侧表示的水属性怪兽
function c2102065.atkfilter2(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 选择满足条件的场上水属性怪兽作为对象
function c2102065.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2102065.atkfilter2(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c2102065.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的场上水属性怪兽作为对象
	Duel.SelectTarget(tp,c2102065.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选择的场上水属性怪兽的攻击力提升1000
function c2102065.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个攻击力提升效果，提升值为1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
