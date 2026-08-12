--シューティング・ライザー・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把持有比场上的这张卡低的等级的1只怪兽从卡组送去墓地，这张卡的等级下降那只怪兽的等级数值。这个回合，自己不能把那只怪兽以及那些同名怪兽的怪兽效果发动。
-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c68431965.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。把持有比场上的这张卡低的等级的1只怪兽从卡组送去墓地，这张卡的等级下降那只怪兽的等级数值。这个回合，自己不能把那只怪兽以及那些同名怪兽的怪兽效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68431965,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,68431965)
	e1:SetCondition(c68431965.lvlcon)
	e1:SetTarget(c68431965.lvtg1)
	e1:SetOperation(c68431965.lvop1)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68431965,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c68431965.sccon)
	e2:SetTarget(c68431965.sctarg)
	e2:SetOperation(c68431965.scop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是通过同调召唤特殊召唤的
function c68431965.lvlcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动准备：检查自身是否在场，以及卡组中是否存在等级低于自身等级的怪兽
function c68431965.lvtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查卡组中是否存在至少1只等级低于这张卡当前等级且可以送去墓地的怪兽
		and Duel.IsExistingMatchingCard(c68431965.tgfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetLevel()) end
	-- 设置效果处理信息：将卡组中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中等级低于指定数值且能送去墓地的怪兽
function c68431965.tgfilter(c,lv)
	return c:IsLevelBelow(lv-1) and c:IsAbleToGrave()
end
-- 效果①的处理：从卡组将1只等级较低的怪兽送去墓地，降低自身等级，并限制该同名怪兽的效果发动
function c68431965.lvop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or c:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只等级低于这张卡当前等级的怪兽
	local g=Duel.SelectMatchingCard(tp,c68431965.tgfilter,tp,LOCATION_DECK,0,1,1,nil,c:GetLevel())
	-- 如果成功将选中的怪兽送去墓地且自身表侧表示存在
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		and c:IsFaceup() then
		local lv=g:GetFirst():GetLevel()
		-- 这张卡的等级下降那只怪兽的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 这个回合，自己不能把那只怪兽以及那些同名怪兽的怪兽效果发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(1,0)
		e2:SetValue(c68431965.aclimit)
		e2:SetLabel(g:GetFirst():GetCode())
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果，限制玩家在本回合发动该同名怪兽的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 限制发动效果的过滤函数：禁止发动与被送去墓地的怪兽同名的怪兽效果
function c68431965.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
-- 效果②的发动条件：对方回合的主要阶段
function c68431965.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合
	return Duel.GetTurnPlayer()~=tp
		-- 检查当前是否处于主要阶段
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②的发动准备：检查额外卡组中是否存在可以以这张卡为素材进行同调召唤的怪兽
function c68431965.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查额外卡组中是否存在可以使用这张卡作为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置效果处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：选择额外卡组中合法的同调怪兽，并以包含这张卡的场上怪兽为素材进行同调召唤
function c68431965.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以使用这张卡作为素材进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
