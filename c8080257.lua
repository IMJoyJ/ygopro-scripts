--炎の剣舞
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：怪兽特殊召唤的场合才能发动。7星以下的1只「炎之剑士」或者有那个卡名记述的融合怪兽从额外卡组特殊召唤。那之后，可以把场上1只表侧表示怪兽变成里侧守备表示。
-- ②：对方战斗阶段，把墓地的这张卡除外，把自己场上1只里侧守备表示怪兽解放才能发动。把1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（怪兽特召时从额外特召怪兽并可选变里侧）和②效果（对方战斗阶段墓地除外并解放里侧怪兽，从卡组·额外特召怪兽）
function s.initial_effect(c)
	-- 将「炎之剑士」（卡号45231177）注册到该卡的关联卡片密码列表中
	aux.AddCodeList(c,45231177)
	-- ①：怪兽特殊召唤的场合才能发动。7星以下的1只「炎之剑士」或者有那个卡名记述的融合怪兽从额外卡组特殊召唤。那之后，可以把场上1只表侧表示怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段，把墓地的这张卡除外，把自己场上1只里侧守备表示怪兽解放才能发动。把1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤额外卡组中满足特殊召唤条件的7星以下「炎之剑士」或记有该卡名的融合怪兽
function s.spfilter(c,e,tp)
	-- 检查卡片是否为「炎之剑士」或记有该卡名，且等级在7星以下
	return (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsLevelBelow(7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 检查额外卡组怪兽特殊召唤到场上所需的可用怪兽区域是否充足
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 过滤场上可以转为里侧守备表示的表侧表示怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的发动准备与合法性检测函数，设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1只满足特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理函数，特殊召唤额外卡组的怪兽，并可选将场上1只表侧表示怪兽变成里侧守备表示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 若成功选择怪兽，则将其以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查场上是否存在可以变成里侧守备表示的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 询问玩家是否要将场上1只表侧表示怪兽变成里侧守备表示
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽变成里侧守备表示？"
		-- 中断当前效果处理，使后续的表示形式变更处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择场上1只满足条件的表侧表示怪兽
		local sg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		-- 选中该怪兽并向双方玩家展示
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		-- 将选中的怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的发动条件函数，必须在对方的战斗阶段才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
		and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤自己场上可作为解放Cost的里侧守备表示怪兽，且解放后能从卡组或额外卡组特殊召唤符合条件的怪兽
function s.costfilter(c,e,tp)
	return c:IsControler(tp) and c:IsFacedown()
		-- 检查卡组或额外卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- ②效果的发动准备与Cost支付函数，将墓地的这张卡除外并解放自己场上1只里侧守备表示怪兽，设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地的这张卡是否能除外，以及自己场上是否存在可解放的里侧守备表示怪兽
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) end
	-- 将墓地的这张卡除外作为发动Cost
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足条件的里侧守备表示怪兽
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
	-- 解放选中的怪兽作为发动Cost
	Duel.Release(g,REASON_COST)
	-- 设置特殊召唤的操作信息，表示将从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤卡组或额外卡组中满足特殊召唤条件的「炎之剑士」或记有该卡名的怪兽
function s.spfilter2(c,e,tp,sc)
	-- 检查卡片是否为「炎之剑士」或记有该卡名
	return (c:IsCode(45231177) or aux.IsCodeListed(c,45231177))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 若怪兽在卡组，检查解放怪兽后可用的怪兽区域是否充足
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,sc)>0
			-- 若怪兽在额外卡组，检查解放怪兽后可用的额外怪兽区域是否充足
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0)
end
-- ②效果的处理函数，从卡组或额外卡组特殊召唤1只「炎之剑士」或记有该卡名的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
