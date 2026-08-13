--エクソシスター・リタニア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有「救祓少女」怪兽的场合，支付800基本分，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。那之后，可以从以下效果选1个适用。
-- ●进行1只「救祓少女」超量怪兽的超量召唤。
-- ●这个回合自己是已把怪兽超量召唤的场合，对方场上1张卡除外。
function c197042.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽只有「救祓少女」怪兽的场合，支付800基本分，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。那之后，可以从以下效果选1个适用。●进行1只「救祓少女」超量怪兽的超量召唤。●这个回合自己是已把怪兽超量召唤的场合，对方场上1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,197042+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c197042.condition)
	e1:SetCost(c197042.cost)
	e1:SetTarget(c197042.target)
	e1:SetOperation(c197042.activate)
	c:RegisterEffect(e1)
	if not c197042.global_check then
		c197042.global_check=true
		-- 这个回合自己是已把怪兽超量召唤的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetCondition(c197042.checkcon)
		ge1:SetOperation(c197042.checkop)
		-- 将全局效果注册到场地（玩家0），用于监听全场超量召唤成功事件，为后续判断“本回合是否已把怪兽超量召唤”记录标记。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局效果的触发条件：特殊召唤成功的怪兽群中存在超量召唤的怪兽（即任何怪兽以超量召唤方式特殊召唤成功时）。
function c197042.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_XYZ)
end
-- 超量召唤成功时，遍历其中所有超量召唤成功的怪兽，为对应的召唤玩家注册本回合超量召唤标记；当双方都已注册后停止遍历。
function c197042.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonType,nil,SUMMON_TYPE_XYZ)
	local tc=g:GetFirst()
	while tc do
		-- 检查该超量召唤怪兽的召唤玩家是否还没有本回合超量召唤标记（flag代码197042），避免重复注册。
		if Duel.GetFlagEffect(tc:GetSummonPlayer(),197042)==0 then
			-- 为召唤该怪兽的玩家注册1个本回合已进行超量召唤的标记，该标记在结束阶段重置。
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),197042,RESET_PHASE+PHASE_END,0,1)
		end
		-- 若双方玩家都已有本回合超量召唤标记，则无需再为剩余怪兽注册，跳出遍历循环。
		if Duel.GetFlagEffect(0,197042)>0 and Duel.GetFlagEffect(1,197042)>0 then
			break
		end
		tc=g:GetNext()
	end
end
-- 过滤条件：卡片是表侧表示且属于「救祓少女」怪兽（setcode 0x172）。
function c197042.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- 效果发动条件：自己场上存在怪兽，且自己场上的怪兽全部是「救祓少女」怪兽（因此只有救祓少女怪兽的场合才能发动）。
function c197042.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区的怪兽数量（作为总怪兽数，用于比较是否全是救祓少女）。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 返回条件是否满足：场上怪兽数大于0，且该数量等于满足「救祓少女」字段的怪兽数量，从而保证自己场上的怪兽只有「救祓少女」怪兽。
	return ct>0 and ct==Duel.GetMatchingGroupCount(c197042.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- 效果发动cost：检查并支付800基本分作为发动代价。
function c197042.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：判断玩家能否支付800基本分，若能则返回true，否则false。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分。
	Duel.PayLPCost(tp,800)
end
-- 效果发动时的取对象处理：从对方的场上·墓地选择1张可以除外的卡作为对象，并设置除外相关的操作信息。
function c197042.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 效果发动合法性检查：确认对方场上·墓地存在至少1张可以被除外且能成为当前效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 显示“请选择要除外的卡”的提示信息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从对方场上选择可除外的卡作为对象；若场上合法目标不足1张，则从墓地中选择，并将选中的卡登记为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：本连锁将进行除外处理，对象为选中的卡（1张），使得相关卡片能正确响应除外效果。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 过滤条件：额外卡组的怪兽属于「救祓少女」字段，且当前满足超量召唤条件（可作为超量召唤的素材进行超量召唤）。
function c197042.xyzfilter(c)
	return c:IsSetCard(0x172) and c:IsXyzSummonable(nil)
end
-- 效果处理：取对象并将其表侧表示除外；若成功，刷新状态后让玩家从“进行救祓少女超量召唤”“再除外对方场上1张卡”“什么都不做”中选择1个适用。
function c197042.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联（未被逃逸等），并且成功将其除外，才继续执行后续可选效果。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 刷新场地信息，确保除外结果和超量召唤状态等最新信息被同步，供后续判断使用。
		Duel.AdjustAll()
		-- 检查额外卡组中是否存在1张以上满足条件的「救祓少女」超量怪兽可以进行超量召唤，作为选项1的可用条件。
		local b1=Duel.IsExistingMatchingCard(c197042.xyzfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查本回合自己是否已进行过超量召唤（flag>0），且对方场上有1张以上可以除外的卡，作为选项2的可用条件。
		local b2=Duel.GetFlagEffect(tp,197042)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 弹出追加效果选项菜单，让玩家选择要适用的效果（超量召唤/再除外/不适用）。
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(197042,0)},  --"超量召唤"
			{b2,aux.Stringid(197042,1)},  --"选卡除外"
			{true,aux.Stringid(197042,2)})  --"什么都不做"
		if op==1 then
			-- 中断当前效果连锁，使得后续的超量召唤作为另一次效果处理独立进行，避免与前面除外处理错时点。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡片（显示“请选择要特殊召唤的卡”）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只满足「救祓少女」字段且可超量召唤的怪兽。
			local g=Duel.SelectMatchingCard(tp,c197042.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 以场上的怪兽为素材，将选择的怪兽进行超量召唤。
			Duel.XyzSummon(tp,g:GetFirst(),nil)
		elseif op==2 then
			-- 中断当前效果连锁，使得后续的再除外处理独立进行，避免时点冲突。
			Duel.BreakEffect()
			-- 提示玩家选择要除外的对方场上的卡（显示“请选择要除外的卡”）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 从对方场上选择1张可以除外的卡片。
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 手动显示选中卡片的对象动画，并将这些卡标记为当前效果的对象。
			Duel.HintSelection(g)
			-- 将选中的对方场上的卡表侧表示除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
