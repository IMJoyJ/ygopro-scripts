--仁王立ち
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力变成2倍，回合结束时那个守备力变成0。
-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。这个回合，对方只能向作为对象的怪兽攻击。
function c19254117.initial_effect(c)
	-- 效果①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力变成2倍，回合结束时那个守备力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19254117,0))  --"守备力变成2倍"
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19254117+EFFECT_COUNT_CODE_OATH)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c19254117.target)
	e1:SetOperation(c19254117.activate)
	c:RegisterEffect(e1)
	-- 效果②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。这个回合，对方只能向作为对象的怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19254117,1))  --"把墓地的这张卡除外"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c19254117.tgcon)
	-- 将此卡除外作为发动cost。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19254117.tgtg)
	e2:SetOperation(c19254117.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：选择场上表侧表示且守备力大于0的怪兽。
function c19254117.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 设置效果①的目标选择函数，用于筛选符合条件的怪兽。
function c19254117.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19254117.filter(chkc) end
	-- 检查是否满足效果①的发动条件，即场上是否存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c19254117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的怪兽作为效果①的对象。
	Duel.SelectTarget(tp,c19254117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的处理函数，设置目标怪兽守备力变为2倍，并在回合结束时归零。
function c19254117.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建一个改变目标怪兽守备力的效果，使其变为原守备力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(tc:GetDefense()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建一个在回合结束时将目标怪兽守备力归零的效果。
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
-- 回合结束时将目标怪兽守备力归零的处理函数。
function c19254117.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local tc=e:GetHandler()
	-- 创建一个使目标怪兽守备力变为0的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1,true)
	e:Reset()
end
-- 效果②的发动条件函数，判断是否为对方回合且可以进行战斗操作。
function c19254117.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合且可以进行战斗操作。
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤条件：选择未被标记的己方怪兽。
function c19254117.tgfilter(c)
	return c:GetFlagEffect(19254117)==0
end
-- 设置效果②的目标选择函数，用于筛选符合条件的己方怪兽。
function c19254117.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19254117.tgfilter(chkc) end
	-- 检查是否满足效果②的发动条件，即己方场上是否存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c19254117.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果②的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择己方场上的一只怪兽作为效果②的对象。
	Duel.SelectTarget(tp,c19254117.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理函数，使对方只能攻击该怪兽。
function c19254117.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		-- 创建一个使对方只能攻击该怪兽的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(c19254117.atklimit)
		e1:SetLabel(tc:GetRealFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册给对方玩家。
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(19254117,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,0)
	end
end
-- 判断目标怪兽是否为效果②所指定的怪兽。
function c19254117.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
