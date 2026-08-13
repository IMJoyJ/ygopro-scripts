--横取りボーン
-- 效果：
-- ①：对方把怪兽特殊召唤的回合，以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在自己场上守备表示特殊召唤。这张卡从场上离开时那只怪兽除外。那只怪兽从场上离开时这张卡破坏。
function c60621361.initial_effect(c)
	-- ①：对方把怪兽特殊召唤的回合，以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c60621361.condition)
	e1:SetTarget(c60621361.target)
	e1:SetOperation(c60621361.activate)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c60621361.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c60621361.remop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c60621361.descon)
	e4:SetOperation(c60621361.desop)
	c:RegisterEffect(e4)
	if not c60621361.global_check then
		c60621361.global_check=true
		-- ①：对方把怪兽特殊召唤的回合，以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在自己场上守备表示特殊召唤。这张卡从场上离开时那只怪兽除外。那只怪兽从场上离开时这张卡破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c60621361.spcheckop)
		-- 将全局检测效果ge1注册到环境（玩家0），用于监听全场所有怪兽的特殊召唤成功事件，以触发记录flag。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 遍历本次特殊召唤成功的怪兽群体eg，判断是否由玩家0或玩家1特殊召唤，并分别为相应玩家注册一个阶段结束重置的flag标记，以记录该玩家本回合进行过特殊召唤。
function c60621361.spcheckop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if tc:IsSummonPlayer(0) then p1=true else p2=true end
		tc=eg:GetNext()
	end
	-- 若玩家0本回合特殊召唤过怪兽，则给玩家0注册编号60621361的flag，阶段结束重置，数量为1。
	if p1 then Duel.RegisterFlagEffect(0,60621361,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家1本回合特殊召唤过怪兽，则给玩家1注册编号60621361的flag，阶段结束重置，数量为1。
	if p2 then Duel.RegisterFlagEffect(1,60621361,RESET_PHASE+PHASE_END,0,1) end
end
-- 发动条件判断：检查对手（1-tp）是否存在本回合特殊召唤过怪兽的标记，以此决定这张卡是否满足“对方把怪兽特殊召唤的回合”这一发动条件。
function c60621361.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回对手的flag数量是否不为0，即对手本回合是否特殊召唤过怪兽。
	return Duel.GetFlagEffect(1-tp,60621361)~=0
end
-- 判断一张卡片是否能作为效果对象被特殊召唤到己方场上表侧守备表示，用于筛选对方墓地的可特殊召唤怪兽。
function c60621361.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时的目标选择：在连锁处理中若检查具体对象chkc，则验证该对象是否位于对方墓地且符合特殊召唤条件；在发动时chk==0则检查己方主区有空位且对方墓地存在符合条件的对象。
function c60621361.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c60621361.filter(chkc,e,tp) end
	-- 发动条件chk==0时，首先确认己方主要怪兽区有空位，以容纳要特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 接着确认对方墓地存在至少1张能成为对象并被特殊召唤的怪兽（不取对象式存在性检查）。
		and Duel.IsExistingTarget(c60621361.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”，用于后续对象选择的界面显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1张符合filter的怪兽卡作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c60621361.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置当前连锁的处理信息为特殊召唤分类，对象组为g，数量1，目标信息为玩家0、位置0，便于其他卡进行响应和判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：当这张卡和对象仍与效果相关时，将选中的墓地怪兽以表侧守备表示特殊召唤到己方场上，并通过SetCardTarget建立这张卡与那只怪兽的关联，用于后续除外/破坏联动。
function c60621361.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的第一个效果对象，即对方墓地中被选择的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 执行分解式特殊召唤步骤：将目标怪兽以表侧守备表示特殊召唤到己方场上，召唤者/控制者为tp，不进行额外检查和限制。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的分解流程，正式召唤成功并触发所有特殊召唤成功相关时点。
	Duel.SpecialSummonComplete()
end
-- 离场前检测这张卡是否被无效化：若处于无效状态则标记Label为1，否则为0，供后续离场时决定是否执行除外效果。
function c60621361.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 这张卡离场时的处理：若之前检测到自身被无效则跳过；否则取得关联的目标怪兽，若其尚在场上则将其除外，实现“这张卡从场上离开时那只怪兽除外”。
function c60621361.remop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽以表侧表示除外，除外原因记为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 场上的对象怪兽离场条件判断：取得这张卡关联的目标怪兽，若该怪兽包含在本次离场事件组中，则满足破坏这张卡的条件。
function c60621361.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏这张卡自身的效果处理：当关联的目标怪兽离场时，这张卡因效果被破坏。
function c60621361.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡（e:GetHandler()）破坏，对应“那只怪兽从场上离开时这张卡破坏”。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
