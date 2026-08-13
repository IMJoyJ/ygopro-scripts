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
	-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的表侧表示怪兽不能攻击，效果无效化。
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
-- 过滤出场上表侧表示的效果怪兽，作为这张卡发动时可选的对象。
function c50078509.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 发动时的取对象处理：确认存在合法对象后，让玩家从双方怪兽区选择1只表侧表示效果怪兽，并登记无效化操作信息。
function c50078509.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50078509.filter(chkc) end
	-- 发动条件判定：检查双方怪兽区是否存在至少1只表侧表示效果怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c50078509.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 由玩家从双方怪兽区选择1张表侧表示效果怪兽，并将该卡设为这张卡发动时的对象。
	local g=Duel.SelectTarget(tp,c50078509.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设定连锁操作信息：这次效果将对象怪兽的1只作为无效化处理的对象。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理时，若这张卡和对象怪兽均仍关联且对象表侧表示，则把对象怪兽设置为这张卡的永续对象，以便持续适用无效攻击和无效效果。
function c50078509.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断条件：这张卡已设定永续对象，且该对象怪兽因破坏而离场（含有REASON_DESTROY）。
function c50078509.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 满足条件时，破坏这张卡自身。
function c50078509.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡（魔族之链）破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
