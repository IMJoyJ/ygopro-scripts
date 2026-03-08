--バーバリアン・レイジ
-- 效果：
-- ①：以自己场上1只战士族怪兽为对象才能把这张卡发动。那只怪兽的攻击力上升1000，那只怪兽战斗破坏的怪兽不送去墓地回到持有者手卡。作为对象的怪兽从场上离开时这张卡破坏。
function c42233477.initial_effect(c)
	-- 以自己场上1只战士族怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果不能在伤害计算后进行。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c42233477.target)
	e1:SetOperation(c42233477.activate)
	c:RegisterEffect(e1)
	-- 作为对象的怪兽从场上离开时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c42233477.descon)
	e2:SetOperation(c42233477.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- 那只怪兽战斗破坏的怪兽不送去墓地回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(LOCATION_HAND)
	c:RegisterEffect(e4)
end
-- 筛选场上表侧表示的战士族怪兽。
function c42233477.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 选择场上1只表侧表示的战士族怪兽作为对象。
function c42233477.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42233477.filter(chkc) end
	-- 检查场上是否存在符合条件的怪兽对象。
	if chk==0 then return Duel.IsExistingTarget(c42233477.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽对象。
	Duel.SelectTarget(tp,c42233477.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选中的怪兽设为效果对象。
function c42233477.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断对象怪兽是否离开场上的条件。
function c42233477.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 对象怪兽离开场上时破坏此卡。
function c42233477.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
