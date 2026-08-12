--『焔聖剣－オートクレール』
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡装备中的场合，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽在同1次的战斗阶段中可以作2次攻击。那之后，这张卡破坏。
-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
function c64867422.initial_effect(c)
	-- 作为装备魔法卡发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c64867422.target)
	e1:SetOperation(c64867422.operation)
	c:RegisterEffect(e1)
	-- 装备限制
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡装备中的场合，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽在同1次的战斗阶段中可以作2次攻击。那之后，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64867422,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,64867422)
	e3:SetCondition(c64867422.excon)
	e3:SetTarget(c64867422.extg)
	e3:SetOperation(c64867422.exop)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(64867422,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,64867422)
	e4:SetCondition(c64867422.descon)
	e4:SetTarget(c64867422.destg)
	e4:SetOperation(c64867422.desop)
	c:RegisterEffect(e4)
end
-- 作为装备魔法卡发动时的对象选择与效果处理准备
function c64867422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 作为装备魔法卡发动时的效果处理（将这张卡装备给目标怪兽）
function c64867422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果①的发动条件：当前回合玩家可以进入战斗阶段
function c64867422.excon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤未拥有追加攻击效果的表侧表示怪兽
function c64867422.exfilter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果①的对象选择与效果处理准备
function c64867422.extg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c64867422.exfilter(chkc) end
	-- 检查自己场上是否存在未拥有追加攻击效果的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c64867422.exfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c64867422.exfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：赋予目标怪兽2次攻击能力，限制其他怪兽攻击，并破坏这张卡
function c64867422.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 这个回合，自己不用那只怪兽不能攻击宣言，那之后，这张卡破坏。②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(c64867422.ftarget)
		e2:SetLabel(tc:GetFieldID())
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制其他怪兽攻击宣言的全局效果
		Duel.RegisterEffect(e2,tp)
		-- 中断当前效果，使后续的破坏处理不与前面的效果同时处理
		Duel.BreakEffect()
		-- 破坏这张卡
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 过滤非目标怪兽（使其不能进行攻击宣言）
function c64867422.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果②的发动条件：因装备怪兽被送去墓地导致这张卡被送去墓地
function c64867422.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsLocation(LOCATION_GRAVE)
end
-- 效果②的对象选择与效果处理准备
function c64867422.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以破坏的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：破坏目标怪兽
function c64867422.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
