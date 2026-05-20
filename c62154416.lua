--マジカルフィシアリスト
-- 效果：
-- 这张卡召唤成功时，给这张卡放置1个魔力指示物（最多1个）。此外，自己的主要阶段时可以通过把这张卡放置的1个魔力指示物取除，选择自己场上1只怪兽那个攻击力直到结束阶段时上升500。
function c62154416.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,1)
	-- 这张卡召唤成功时，给这张卡放置1个魔力指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62154416,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c62154416.addct)
	e1:SetOperation(c62154416.addc)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时可以通过把这张卡放置的1个魔力指示物取除，选择自己场上1只怪兽那个攻击力直到结束阶段时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62154416,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c62154416.atkcost)
	e2:SetTarget(c62154416.atktg)
	e2:SetOperation(c62154416.atkop)
	c:RegisterEffect(e2)
end
-- 召唤成功时放置魔力指示物效果的发动准备与操作信息设置
function c62154416.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果的处理为放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 召唤成功时放置魔力指示物效果的处理：若自身仍在场，则给自身放置1个魔力指示物
function c62154416.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 攻击力上升效果的代价：取除自身1个魔力指示物
function c62154416.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
-- 攻击力上升效果的对象选择：选择自己场上1只表侧表示的怪兽
function c62154416.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 攻击力上升效果的处理：使选择的怪兽攻击力直到结束阶段时上升500
function c62154416.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那个攻击力直到结束阶段时上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
