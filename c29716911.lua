--コンデンサー・デスストーカー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。这只怪兽表侧表示存在期间，那只怪兽的攻击力上升800。
-- ②：怪兽区域的这张卡被效果破坏送去墓地的场合发动。双方玩家受到800伤害。
function c29716911.initial_effect(c)
	-- ①：这张卡召唤成功时，以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。这只怪兽表侧表示存在期间，那只怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29716911,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c29716911.atktg)
	e1:SetOperation(c29716911.atkop)
	c:RegisterEffect(e1)
	-- ②：怪兽区域的这张卡被效果破坏送去墓地的场合发动。双方玩家受到800伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29716911,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,29716911)
	e2:SetCondition(c29716911.condition)
	e2:SetTarget(c29716911.target)
	e2:SetOperation(c29716911.operation)
	c:RegisterEffect(e2)
end
-- 筛选条件：表侧表示的电子界族怪兽
function c29716911.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 选择对象：自己场上1只表侧表示的电子界族怪兽
function c29716911.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c29716911.atkfilter(chkc) and chkc~=c end
	-- 确认是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c29716911.atkfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的电子界族怪兽作为对象
	Duel.SelectTarget(tp,c29716911.atkfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 将对象怪兽的攻击力上升800
function c29716911.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 为对象怪兽设置攻击力上升800的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetCondition(c29716911.rcon)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断对象怪兽是否仍存在于场上
function c29716911.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 判断破坏时是否从怪兽区域送去墓地
function c29716911.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 设置伤害效果的处理信息
function c29716911.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置双方各受到800伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,800)
end
-- 对双方玩家各造成800伤害
function c29716911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对玩家tp造成800伤害
	Duel.Damage(tp,800,REASON_EFFECT,true)
	-- 对玩家(1-tp)造成800伤害
	Duel.Damage(1-tp,800,REASON_EFFECT,true)
	-- 触发伤害处理的时点
	Duel.RDComplete()
end
