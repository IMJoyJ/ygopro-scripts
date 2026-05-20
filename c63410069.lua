--砂漠の飛蝗賊
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功的场合发动。回合玩家选自身1张手卡丢弃。
-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
function c63410069.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡同调召唤成功的场合发动。回合玩家选自身1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63410069,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,63410069)
	e1:SetCondition(c63410069.diccon)
	e1:SetTarget(c63410069.dictg)
	e1:SetOperation(c63410069.dicop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63410069,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c63410069.sscon)
	e2:SetTarget(c63410069.sstg)
	e2:SetOperation(c63410069.ssop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡同调召唤成功
function c63410069.diccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动准备：设置丢弃手牌的操作信息
function c63410069.dictg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的参数为1（丢弃1张手牌）
	Duel.SetTargetParam(1)
	-- 设置操作信息：回合玩家丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,Duel.GetTurnPlayer(),1)
end
-- 效果①的效果处理：回合玩家选择自身1张手牌丢弃
function c63410069.dicop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local p=Duel.GetTurnPlayer()
	-- 获取效果处理的参数（丢弃的手牌数量）
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取回合玩家的手牌
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()>0 then
		-- 提示回合玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(p,1,1,nil)
		-- 将选中的手牌因效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 效果②的发动条件：对方的主要阶段
function c63410069.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②的发动准备：检查是否存在可同调召唤的怪兽并设置特殊召唤的操作信息
function c63410069.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动检测：检查额外卡组是否存在可以用这张卡作为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：用包含这张卡的自己场上的怪兽为同调素材作同调召唤
function c63410069.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以用这张卡作为素材进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
