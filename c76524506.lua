--ガーデン・ローズ・フローラ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以场上1张场地魔法卡为对象才能发动。那张卡破坏。那之后，在那个控制者场上把1只「蔷薇衍生物」（植物族·暗·2星·攻/守800）攻击表示特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材作同调召唤。
function c76524506.initial_effect(c)
	-- 设置同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：以场上1张场地魔法卡为对象才能发动。那张卡破坏。那之后，在那个控制者场上把1只「蔷薇衍生物」（植物族·暗·2星·攻/守800）攻击表示特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76524506,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,76524506)
	e1:SetTarget(c76524506.destg)
	e1:SetOperation(c76524506.desop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76524506,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c76524506.sccon)
	e2:SetTarget(c76524506.sctg)
	e2:SetOperation(c76524506.scop)
	c:RegisterEffect(e2)
end
-- 定义场地魔法卡破坏及衍生物特殊召唤的过滤条件
function c76524506.desfilter(c,tp)
	local p=c:GetControler()
	-- 检查场地魔法卡的控制者场上是否有怪兽区域空位，且自己是否能将衍生物特殊召唤到该玩家场上
	return Duel.GetLocationCount(p,LOCATION_MZONE,tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,71645243,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,p)
end
-- 效果①的发动准备：检查并选择要破坏的场地魔法卡，设置破坏、特殊召唤和衍生物生成的操作信息
function c76524506.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_FZONE) and c76524506.desfilter(chkc,tp) end
	-- 检查场上是否存在可以作为效果对象的场地魔法卡
	if chk==0 then return Duel.IsExistingTarget(c76524506.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张符合条件的场地魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c76524506.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil,tp)
	-- 设置操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：包含特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息：包含衍生物效果
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果①的效果处理：破坏对象卡，并在其控制者场上特殊召唤「蔷薇衍生物」，最后施加本回合只能特殊召唤同调怪兽的限制
function c76524506.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（即选中的场地魔法卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local p=tc:GetControler()
		-- 若成功破坏该卡，且该卡控制者场上有空位并能特殊召唤衍生物，则进行后续处理
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(p,LOCATION_MZONE,tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,71645243,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,p) then
			-- 中断效果处理，使后续的特殊召唤处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 创建「蔷薇衍生物」卡片数据
			local token=Duel.CreateToken(tp,76524507)
			-- 将「蔷薇衍生物」以攻击表示特殊召唤到该场地魔法卡控制者的场上
			Duel.SpecialSummon(token,0,tp,p,false,false,POS_FACEUP_ATTACK)
		end
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材作同调召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c76524506.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该额外卡组特殊召唤限制效果给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制非同调怪兽不能从额外卡组特殊召唤
function c76524506.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动条件：对方回合的主要阶段
function c76524506.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
		-- 检查当前是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②的发动准备：检查额外卡组中是否存在可以使用包含这张卡的场上怪兽作为素材进行同调召唤的怪兽
function c76524506.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查额外卡组是否存在可以使用这张卡作为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：在对方主要阶段，使用包含这张卡的自己场上怪兽为素材进行同调召唤
function c76524506.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsControler(tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以使用这张卡作为素材进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 使用包含这张卡的场上怪兽作为素材，对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
