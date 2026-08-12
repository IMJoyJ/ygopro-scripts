--猪突猛進
-- 效果：
-- ①：宣言1个属性，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只自己的表侧表示怪兽和持有宣言的属性的对方怪兽进行战斗的场合，那次伤害步骤开始时那只对方怪兽破坏。
function c48422921.initial_effect(c)
	-- ①：宣言1个属性，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只自己的表侧表示怪兽和持有宣言的属性的对方怪兽进行战斗的场合，那次伤害步骤开始时那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 判断是否处于可以进行战斗相关操作的时点或阶段
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c48422921.target)
	e1:SetOperation(c48422921.operation)
	c:RegisterEffect(e1)
end
-- 选择效果的对象：自己场上1只表侧表示怪兽
function c48422921.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只自己场上的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	local val=ATTRIBUTE_ALL
	local reg=g:GetFirst():GetFlagEffectLabel(48422921)
	if reg then val=val-reg end
	-- 提示玩家宣言属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性
	local att=Duel.AnnounceAttribute(tp,1,val)
	e:SetLabel(att)
end
-- 将效果注册到目标怪兽上，使其在战斗开始时触发破坏效果
function c48422921.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local att=e:GetLabel()
		-- 当目标怪兽进入战斗阶段开始时，若对方怪兽具有宣言的属性则将其破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetLabel(att)
		e1:SetOwnerPlayer(tp)
		e1:SetCondition(c48422921.descon)
		e1:SetOperation(c48422921.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		local reg=tc:GetFlagEffectLabel(48422921)
		if reg then
			reg=bit.bor(reg,att)
			tc:SetFlagEffectLabel(48422921,reg)
		else
			tc:RegisterFlagEffect(48422921,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,att)
		end
	end
end
-- 判断是否为己方怪兽与敌方怪兽进行战斗且敌方怪兽具有宣言的属性
function c48422921.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tp==e:GetOwnerPlayer() and tc and tc:IsControler(1-tp) and tc:IsAttribute(e:GetLabel())
end
-- 将符合条件的对方怪兽破坏
function c48422921.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 以效果为原因破坏目标怪兽
	Duel.Destroy(tc,REASON_EFFECT)
end
