--BF－雪撃のチヌーク
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把手卡·场上的这张卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动（自己场上有暗属性同调怪兽存在的场合，这个效果在对方回合也能发动）。从额外卡组把1只「黑羽」同调怪兽或「黑翼龙」送去墓地，作为对象的怪兽直到回合结束时攻击力下降700，效果无效化。
function c34976176.initial_effect(c)
	-- 将该卡效果文中记载的「黑翼龙」（卡号9012916）登记到该卡的卡名列表中，以便进行关联判定。
	aux.AddCodeList(c,9012916)
	-- ①：把手卡·场上的这张卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动（自己场上有暗属性同调怪兽存在的场合，这个效果在对方回合也能发动）。从额外卡组把1只「黑羽」同调怪兽或「黑翼龙」送去墓地，作为对象的怪兽直到回合结束时攻击力下降700，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34976176,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,34976176)
	e1:SetCondition(c34976176.discon1)
	e1:SetCost(c34976176.discost)
	e1:SetTarget(c34976176.distg)
	e1:SetOperation(c34976176.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c34976176.discon2)
	c:RegisterEffect(e2)
end
-- 判断是否为表侧表示的暗属性同调怪兽，用于检查自己场上是否存在可触发对方回合发动的暗属性同调怪兽。
function c34976176.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 主阶段起动效果的发动条件：自己场上不存在表侧表示的暗属性同调怪兽时才能发动。
function c34976176.discon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上不存在表侧表示的暗属性同调怪兽。
	return not Duel.IsExistingMatchingCard(c34976176.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 对方回合也能发动时的条件：自己场上存在表侧表示的暗属性同调怪兽，且处于伤害步骤内允许发动的时机（伤害计算前）。
function c34976176.discon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上存在表侧表示的暗属性同调怪兽。
	return Duel.IsExistingMatchingCard(c34976176.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时满足伤害步骤限制：当前不是伤害步骤，或尚未进行伤害计算，保证该即时效果可在伤害计算前发动。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 发动代价：检查这张卡能否作为代价送去墓地，若能则将其从手卡或场上送去墓地。
function c34976176.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将发动效果的本体卡（这张卡）送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 选择对象怪兽的过滤器：表侧表示，且为可被无效化效果的效果怪兽或攻击力大于0的怪兽。
function c34976176.filter(c)
	-- 要求对象为表侧表示，并且要么是可以被无效化效果的效果怪兽，要么攻击力大于0。
	return c:IsFaceup() and (aux.NegateMonsterFilter(c) or c:GetAttack()>0)
end
-- 额外卡组检索/送去墓地的过滤器：满足“黑羽”同调怪兽或卡号9012916（黑翼龙）且能送去墓地。
function c34976176.tgfilter(c)
	return c:IsAbleToGrave() and ((c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO)) or c:IsCode(9012916))
end
-- 效果发动的目标处理：选择对方场上1只表侧表示怪兽为对象，并确认额外卡组有可送去墓地的「黑羽」同调怪兽或「黑翼龙」。
function c34976176.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c34976176.filter(chkc) end
	-- 发动时自检：存在1张以上可选择为对象的对方表侧怪兽。
	if chk==0 then return Duel.IsExistingTarget(c34976176.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 并且额外卡组存在1张以上符合条件的「黑羽」同调怪兽或「黑翼龙」可送去墓地。
		and Duel.IsExistingMatchingCard(c34976176.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示操作者选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只满足条件的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,c34976176.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向系统登记操作信息：效果处理时将从额外卡组把1张卡送去墓地（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选1张符合条件的「黑羽」同调怪兽或「黑翼龙」送去墓地；若成功且对象仍然合法，则将对象怪兽无效化并使其攻击力下降700直到回合结束。
function c34976176.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 提示操作者选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1张符合条件的「黑羽」同调怪兽或「黑翼龙」。
	local g=Duel.SelectMatchingCard(tp,c34976176.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 确认选到了卡且成功送去墓地，并且该卡现在在墓地；同时对象怪兽仍表侧表示且与本效果关联，才继续处理。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与对象怪兽相关的连锁无效化，并在对象变里侧表示时重置该无效化状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 作为对象的怪兽直到回合结束时效果无效化（对应原文“效果无效化”）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使对象怪兽发动的效果无效化（对应原文“效果无效化”）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 作为对象的怪兽直到回合结束时攻击力下降700（对应原文“攻击力下降700”）。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(-700)
		tc:RegisterEffect(e3)
	end
end
