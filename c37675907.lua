--アクセル・シンクロン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「加速同调士」1回合只能有1次同调召唤。
-- ①：1回合1次，可以从卡组把1只「同调士」怪兽送去墓地，从以下效果选择1个发动。
-- ●这张卡的等级上升那只怪兽的等级数值。
-- ●这张卡的等级下降那只怪兽的等级数值。
-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c37675907.initial_effect(c)
	-- 为这张卡添加同调召唤手续，素材要求为：调整怪兽任意1只＋调整以外的怪兽1只以上（即“调整＋调整以外的怪兽1只以上”），其中调整素材不限制种族/属性等，非调整素材由aux.NonTuner(nil)表示任意调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 自己对「加速同调士」1回合只能有1次同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37675907.regcon)
	e1:SetOperation(c37675907.regop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以从卡组把1只「同调士」怪兽送去墓地，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37675907,0))  --"等级改变"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c37675907.tgcost)
	e2:SetTarget(c37675907.tgtg)
	e2:SetOperation(c37675907.tgop)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37675907,1))  --"同调召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c37675907.spcon)
	e3:SetTarget(c37675907.sptg)
	e3:SetOperation(c37675907.spop)
	c:RegisterEffect(e3)
end
-- 该效果触发条件：此卡以同调召唤方式特殊召唤成功时，才进行后续的限制效果注册。
function c37675907.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 在此卡同调召唤成功时，为己方玩家注册一个持续效果，该效果在结束阶段前禁止己方以同调召唤方式特殊召唤「加速同调士」（卡号37675907），以此实现“自己对「加速同调士」1回合只能有1次同调召唤”的限制。
function c37675907.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己对「加速同调士」1回合只能有1次同调召唤。①：1回合1次，可以从卡组把1只「同调士」怪兽送去墓地，从以下效果选择1个发动。●这张卡的等级上升那只怪兽的等级数值。●这张卡的等级下降那只怪兽的等级数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c37675907.splimit)
	-- 将创建好的“不能特殊召唤加速同调士”的持续效果注册给当前玩家tp，使该限制效果在场上持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤条件：被特殊召唤的怪兽必须是「加速同调士」（卡号37675907），且召唤方式为同调召唤，满足这两个条件时禁止该特殊召唤。
function c37675907.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(37675907) and bit.band(sumtype,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
-- ①效果的检索/代价筛选条件：从卡组选择1只等级大于0、持有「同调士」字段（0x1017）且可以作为代价送去墓地的怪兽。
function c37675907.filter(c)
	return c:GetLevel()>0 and c:IsSetCard(0x1017) and c:IsAbleToGraveAsCost()
end
-- ①效果的发动代价：从卡组选择1只符合条件的「同调士」怪兽送去墓地，并将其记录到效果标签中，供后续效果处理时读取该怪兽的等级。
function c37675907.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：卡组中是否存在至少1只满足filter条件的「同调士」怪兽，若不存在则无法支付代价，效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37675907.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示“请选择要送去墓地的卡”的提示，引导玩家从卡组选择要作为代价送去墓地的「同调士」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从己方卡组选择1只满足filter条件的「同调士」怪兽，作为①效果的发动代价。
	local g=Duel.SelectMatchingCard(tp,c37675907.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的「同调士」怪兽以代价（COST）形式从卡组送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- ①效果的发动目标处理：获取此卡当前等级，根据被送去墓地的「同调士」怪兽等级与此卡等级的比较结果，决定向玩家展示的选项（等级上升，或等级上升/等级下降），并把玩家选择的选项存入效果标签。
function c37675907.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	if chk==0 then return lv>0 end
	local opt
	if e:GetLabelObject():GetLevel()<lv then
		-- 当墓地的「同调士」怪兽等级低于此卡等级时，给出“等级上升”和“等级下降”两个选项，返回值0表示上升、1表示下降，存入效果标签供处理阶段使用。
		opt=Duel.SelectOption(tp,aux.Stringid(37675907,2),aux.Stringid(37675907,3))  --"等级上升/等级下降"
	else
		-- 当墓地的「同调士」怪兽等级不低于此卡等级时，等级下降会使等级变为0或负数，因此只提供“等级上升”一个合法选项。
		opt=Duel.SelectOption(tp,aux.Stringid(37675907,2))  --"等级上升"
	end
	e:SetLabel(opt)
end
-- ①效果的实际处理：若此卡仍与效果关联且表侧表示，则根据之前选择的选项，给此卡附加等级上升或下降效果，数值等于被送去墓地的「同调士」怪兽的等级。
function c37675907.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabelObject():GetLevel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- ●这张卡的等级上升那只怪兽的等级数值。●这张卡的等级下降那只怪兽的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if e:GetLabel()==0 then
			e1:SetValue(lv)
		else
			e1:SetValue(-lv)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：只能在对方的主要阶段（主阶段1或2）发动，即当前不是自己的回合且处于主要阶段，才能进行同调召唤。
function c37675907.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于后续判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为对方主要阶段：当前回合玩家不是己方且阶段为PHASE_MAIN1或PHASE_MAIN2时返回真，满足②效果只能在对方主要阶段发动的限制。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- ②效果的发动合法性检查：此卡当前不在连锁处理中（确保同一连锁上最多发动1次），并且额外卡组存在能以这张卡为素材进行同调召唤的怪兽。
function c37675907.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 追加检查额外卡组中是否有“可以用这张卡作为同调素材”的同调怪兽存在，若没有则不能发动②效果。
		and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 将②效果的操作信息登记为“特殊召唤”，目标是从额外卡组特殊召唤1只同调怪兽，具体的同调召唤对象在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：确认此卡依然由自己控制、与效果关联且表侧表示后，从额外卡组选出1只可用此卡作为素材的同调怪兽，立即进行同调召唤。
function c37675907.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有能以这张卡作为同调素材进行同调召唤的同调怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 显示“请选择要特殊召唤的卡”的提示，让玩家从符合条件的同调怪兽中选择1只进行同调召唤。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡作为同调素材（调整），将玩家选择的同调怪兽进行同调召唤，完成②效果。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
