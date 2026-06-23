--ムーンダンスの儀式
-- 效果：
-- ①：以自己场上1只没有超量素材的风属性超量怪兽为对象才能把这张卡发动。只要那只怪兽在场上存在，场上的表侧表示怪兽的效果无效化。作为对象的怪兽从场上离开时这张卡破坏。
-- ②：这张卡发动的回合的结束阶段发动。把场上的这张卡在这张卡的发动时作为对象的怪兽下面重叠作为超量素材。
function c14005031.initial_effect(c)
	-- ①：以自己场上1只没有超量素材的风属性超量怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c14005031.target)
	e1:SetOperation(c14005031.activate)
	c:RegisterEffect(e1)
	-- 只要那只怪兽在场上存在，场上的表侧表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c14005031.disable)
	e2:SetCondition(c14005031.discon)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- 作为对象的怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c14005031.descon)
	e3:SetOperation(c14005031.desop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的风属性超量怪兽（无超量素材）
function c14005031.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0 and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 处理效果选择对象的函数
function c14005031.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c14005031.filter(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c14005031.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择满足条件的怪兽作为对象
	Duel.SelectTarget(tp,c14005031.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果发动时的函数
function c14005031.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- ②：这张卡发动的回合的结束阶段发动。把场上的这张卡在这张卡的发动时作为对象的怪兽下面重叠作为超量素材。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(14005031,0))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(c14005031.matop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否为效果怪兽
function c14005031.disable(e,c)
	return c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT
end
-- 判断是否满足效果无效化的条件
function c14005031.discon(e)
	return e:GetHandler():GetFirstCardTarget()~=nil
end
-- 判断是否满足破坏条件
function c14005031.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 处理破坏效果
function c14005031.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 处理将自身作为超量素材的函数
function c14005031.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc then
		-- 将自身叠放至对象怪兽下方作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
