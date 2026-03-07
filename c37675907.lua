--アクセル・シンクロン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「加速同调士」1回合只能有1次同调召唤。
-- ①：1回合1次，可以从卡组把1只「同调士」怪兽送去墓地，从以下效果选择1个发动。
-- ●这张卡的等级上升那只怪兽的等级数值。
-- ●这张卡的等级下降那只怪兽的等级数值。
-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c37675907.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
-- 判断是否为同调召唤成功
function c37675907.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 注册一个永续效果，使对方不能特殊召唤「加速同调士」
function c37675907.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个永续效果，使对方不能特殊召唤「加速同调士」
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c37675907.splimit)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制对方不能特殊召唤「加速同调士」
function c37675907.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(37675907) and bit.band(sumtype,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
-- 过滤函数，筛选等级大于0且为「同调士」的怪兽
function c37675907.filter(c)
	return c:GetLevel()>0 and c:IsSetCard(0x1017) and c:IsAbleToGraveAsCost()
end
-- 检查玩家手牌是否存在满足条件的「同调士」怪兽，并选择1只送去墓地
function c37675907.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在满足条件的「同调士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37675907.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「同调士」怪兽
	local g=Duel.SelectMatchingCard(tp,c37675907.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 选择等级上升或下降效果
function c37675907.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	if chk==0 then return lv>0 end
	local opt
	if e:GetLabelObject():GetLevel()<lv then
		-- 选择等级上升效果
		opt=Duel.SelectOption(tp,aux.Stringid(37675907,2),aux.Stringid(37675907,3))  --"等级上升/等级下降"
	else
		-- 选择等级下降效果
		opt=Duel.SelectOption(tp,aux.Stringid(37675907,2))  --"等级上升"
	end
	e:SetLabel(opt)
end
-- 根据选择的效果修改卡片等级
function c37675907.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabelObject():GetLevel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置等级变化效果
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
-- 判断是否为对方主要阶段
function c37675907.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为对方回合且处于主要阶段
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 判断是否可以发动效果
function c37675907.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查是否存在满足条件的同调怪兽
		and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动同调召唤效果
function c37675907.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取满足条件的同调怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
