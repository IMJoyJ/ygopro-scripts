--カラクリ忍者 参参九
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。这张卡反转时，选择场上表侧表示存在的1只怪兽送去墓地。此外，这张卡反转的回合，这张卡可以直接攻击对方玩家。
function c93724592.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93724592,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c93724592.poscon)
	e3:SetOperation(c93724592.posop)
	c:RegisterEffect(e3)
	-- 这张卡反转时，选择场上表侧表示存在的1只怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93724592,1))  --"送去墓地"
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c93724592.tgtg)
	e4:SetOperation(c93724592.tgop)
	c:RegisterEffect(e4)
	-- 此外，这张卡反转的回合，这张卡可以直接攻击对方玩家。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_FLIP)
	e5:SetOperation(c93724592.dirop)
	c:RegisterEffect(e5)
end
-- 判断自身是否处于攻击表示（作为被选择作为攻击对象时改变表示形式效果的发动条件）
function c93724592.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 被选择作为攻击对象时效果的处理：若自身表侧表示存在且此卡与效果有关联，则将自身变为表侧守备表示
function c93724592.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将自身表示形式改变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 反转时送去墓地效果的目标选择与发动准备：选择场上表侧表示存在的1只怪兽作为对象，并设置送去墓地的操作信息
function c93724592.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上表侧表示存在的1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 反转时送去墓地效果的处理：若目标怪兽仍表侧表示存在且与效果有关联，则将其送去墓地
function c93724592.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的第一个对象（即要送去墓地的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 反转时触发的辅助效果处理：为自身注册一个在本回合内可以直接攻击对方玩家的效果
function c93724592.dirop(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
