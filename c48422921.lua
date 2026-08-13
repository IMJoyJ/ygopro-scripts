--猪突猛進
-- 效果：
-- ①：宣言1个属性，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只自己的表侧表示怪兽和持有宣言的属性的对方怪兽进行战斗的场合，那次伤害步骤开始时那只对方怪兽破坏。
function c48422921.initial_effect(c)
	-- ①：宣言1个属性，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只自己的表侧表示怪兽和持有宣言的属性的对方怪兽进行战斗的场合，那次伤害步骤开始时那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果发动条件为处于战斗阶段或可进入战斗阶段（aux.bpcon），即只能在主要阶段或战斗阶段中发动。
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c48422921.target)
	e1:SetOperation(c48422921.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与属性宣言处理：先取我方场上表侧表示怪兽作为对象，再从全属性中剔除该对象已记录过的属性后，让玩家宣言1个属性，并将宣言结果存到e的Label中备用。
function c48422921.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动时（chk==0）检查是否存在满足条件的对象：我方场上存在至少1只表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示信息，引导玩家选择目标卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让我方玩家从我方怪兽区选择1只表侧表示怪兽作为效果对象，并通过Duel.SelectTarget将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	local val=ATTRIBUTE_ALL
	local reg=g:GetFirst():GetFlagEffectLabel(48422921)
	if reg then val=val-reg end
	-- 向玩家显示“请选择要宣言的属性”的提示信息，用于接下来的属性宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可选属性中宣言1个属性，将宣言结果记录在att中，随后保存到效果e的Label作为本次宣言的属性。
	local att=Duel.AnnounceAttribute(tp,1,val)
	e:SetLabel(att)
end
-- 效果处理：若对象怪兽仍与效果关联且表侧表示，则给它附加一个持续效果——当它与宣言属性的对方怪兽进行战斗时，那次伤害步骤开始时破坏那只对方怪兽；同时用标志记录本次宣言的属性，供后续发动时排除重复属性。
function c48422921.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的效果对象（即被选择的我方表侧表示怪兽），后续处理将基于此对象进行。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local att=e:GetLabel()
		-- 这个回合，那只自己的表侧表示怪兽和持有宣言的属性的对方怪兽进行战斗的场合，那次伤害步骤开始时那只对方怪兽破坏。
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
-- 持续效果的触发条件：对象怪兽正在与对方怪兽战斗，对方怪兽的属性等于宣言的属性，且该战斗事件属于效果所有者（通过tp==e:GetOwnerPlayer()判断）。
function c48422921.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tp==e:GetOwnerPlayer() and tc and tc:IsControler(1-tp) and tc:IsAttribute(e:GetLabel())
end
-- 持续效果触发后的处理：获取正在进行战斗的对方怪兽作为破坏对象。
function c48422921.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 以卡牌效果为原因将那只对方怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
