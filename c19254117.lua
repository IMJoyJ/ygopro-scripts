--仁王立ち
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力变成2倍，回合结束时那个守备力变成0。
-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。这个回合，对方只能向作为对象的怪兽攻击。
function c19254117.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力变成2倍，回合结束时那个守备力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19254117,0))  --"守备力变成2倍"
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19254117+EFFECT_COUNT_CODE_OATH)
	-- 设置效果发动条件为伤害步骤限制：当前不是伤害步骤或尚未进行伤害计算时才能发动，即不能在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c19254117.target)
	e1:SetOperation(c19254117.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。这个回合，对方只能向作为对象的怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19254117,1))  --"把墓地的这张卡除外"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c19254117.tgcon)
	-- 设置②效果的发动COST为把墓地中的这张卡除外（通过aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19254117.tgtg)
	e2:SetOperation(c19254117.tgop)
	c:RegisterEffect(e2)
end
-- 定义①效果可选择对象的筛选条件：场上的表侧表示怪兽且守备力大于0。
function c19254117.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- ①效果的目标选择函数：发动时检查指定对象是否合法，并选择场上1只表侧表示且守备力大于0的怪兽作为对象。
function c19254117.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19254117.filter(chkc) end
	-- 效果发动合法性检查：确认场上存在至少1只符合条件的表侧表示怪兽可选，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c19254117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示消息，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动者从自己或对方场上选择1只表侧表示且守备力大于0的怪兽作为效果对象，并设为连锁对象。
	Duel.SelectTarget(tp,c19254117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：获取对象怪兽，若对象仍相关且表侧表示，则先将其守备力变为当前守备力的2倍（暂时改变），再注册一个在回合结束时把守备力变为0的触发效果。
function c19254117.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的守备力变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(tc:GetDefense()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 回合结束时那个守备力变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_TURN_END)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetCountLimit(1)
		e2:SetOperation(c19254117.ddop)
		tc:RegisterEffect(e2)
	end
end
-- 回合结束时的处理：将对象怪兽的守备力设置为0，并重置掉之前设置的守备力变化效果。
function c19254117.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local tc=e:GetHandler()
	-- 回合结束时那个守备力变成0；②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。这个回合，对方只能向作为对象的怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1,true)
	e:Reset()
end
-- ②效果的发动条件函数：仅在自己回合外且满足战斗阶段/主要阶段时机且非伤害计算后时才能发动。
function c19254117.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前不是自己的回合，并且当前处于可发动②效果的战斗阶段/主要阶段时机（非伤害计算后）。
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义②效果对象筛选条件：该怪兽未被本卡标记过（FlagEffect为0），即尚未作为②效果的对象。
function c19254117.tgfilter(c)
	return c:GetFlagEffect(19254117)==0
end
-- ②效果的目标选择函数：检查指定对象是否合法，并选择自己场上1只符合条件的怪兽作为对象。
function c19254117.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19254117.tgfilter(chkc) end
	-- ②效果发动合法性检查：确认自己场上存在至少1只符合条件的怪兽可选。
	if chk==0 then return Duel.IsExistingTarget(c19254117.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示消息，提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动者选择自己场上1只符合条件的怪兽作为效果对象，并设为连锁对象。
	Duel.SelectTarget(tp,c19254117.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：若对象仍相关，则给对方的怪兽区域施加“只能攻击对象怪兽”的限制效果，持续到回合结束，并给对象怪兽打上标记。
function c19254117.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，对方只能向作为对象的怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(c19254117.atklimit)
		e1:SetLabel(tc:GetRealFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将“对方只能攻击对象怪兽”的限制效果注册到场上，使其生效直到回合结束。
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(19254117,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,0)
	end
end
-- 判定攻击怪兽是否为被选中的对象：比较场上怪兽的FieldID与效果记录的对象FieldID，相等则允许其成为攻击对象（即对方只能攻击该对象）。
function c19254117.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
