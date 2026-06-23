--デモンズ・チェーン
-- 效果：
-- 以场上1只效果怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的表侧表示怪兽不能攻击，效果无效化。作为对象的怪兽破坏时这张卡破坏。
function c50078509.initial_effect(c)
	-- 以场上1只效果怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c50078509.target)
	e1:SetOperation(c50078509.tgop)
	c:RegisterEffect(e1)
	-- 作为对象的表侧表示怪兽不能攻击，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
	-- 作为对象的怪兽破坏时这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c50078509.descon)
	e5:SetOperation(c50078509.desop)
	c:RegisterEffect(e5)
end
-- 筛选场上的表侧表示的效果怪兽
function c50078509.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 选择场上1只表侧表示的效果怪兽作为对象
function c50078509.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50078509.filter(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c50078509.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c50078509.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要处理的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理效果发动后的操作，建立对象关系
function c50078509.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断对象怪兽是否因破坏而离场
function c50078509.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当对象怪兽被破坏时，将此卡破坏
function c50078509.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从场上破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
