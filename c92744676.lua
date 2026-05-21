--デンジエビ
-- 效果：
-- 调整＋调整以外的怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合，从自己的手卡·场上把这张卡以外的1张卡送去墓地，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 定义初始化效果，注册同调召唤手续、效果①和效果②
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，从自己的手卡·场上把这张卡以外的1张卡送去墓地，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"进行同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.sccon)
	e2:SetTarget(s.sctarg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
end
-- 效果①的COST处理函数：从自己的手卡·场上把这张卡以外的1张卡送去墓地
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在除自身以外可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择除自身以外的1张卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选择的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：魔法·陷阱卡
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的靶向与发动准备函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏该对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件函数
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合
	return Duel.GetTurnPlayer()~=tp
		-- 检查当前是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②的发动准备函数
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查额外卡组中是否存在可以使用这张卡作为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理函数
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以使用这张卡作为素材进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
