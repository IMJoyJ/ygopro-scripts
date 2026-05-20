--シンクロ・ゾーン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，双方不用同调怪兽不能攻击宣言。
-- ②：调整以外的同调怪兽被战斗以外送去自己墓地的场合，以那之内的1只为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作调整使用。
-- ③：对方主要阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。进行1只同调怪兽的同调召唤。
function c60306277.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方不用同调怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c60306277.tglimit)
	c:RegisterEffect(e1)
	-- ②：调整以外的同调怪兽被战斗以外送去自己墓地的场合，以那之内的1只为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60306277,0))  --"苏生同调怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,60306277)
	e2:SetCondition(c60306277.spcon)
	e2:SetTarget(c60306277.sptg)
	e2:SetOperation(c60306277.spop)
	c:RegisterEffect(e2)
	-- ③：对方主要阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。进行1只同调怪兽的同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60306277,1))  --"同调召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,60306278)
	e3:SetCondition(c60306277.sccon)
	e3:SetCost(c60306277.sccost)
	e3:SetTarget(c60306277.sctg)
	e3:SetOperation(c60306277.scop)
	c:RegisterEffect(e3)
end
-- 限制不能进行攻击宣言的怪兽过滤条件（非同调怪兽不能攻击宣言）
function c60306277.tglimit(e,c)
	return not c:IsType(TYPE_SYNCHRO)
end
-- 过滤送去自己墓地的调整以外的同调怪兽
function c60306277.cfilter(c,tp)
	return not c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
-- 过滤可以作为效果对象且可以特殊召唤的怪兽
function c60306277.spfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否有满足条件的怪兽被送去自己墓地
function c60306277.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60306277.cfilter,1,nil,tp)
end
-- 效果②的靶向与发动准备（选择送去墓地的1只调整以外的同调怪兽为对象，并设置特殊召唤的操作信息）
function c60306277.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c60306277.cfilter,nil,tp):Filter(c60306277.spfilter,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	if chk==0 then return #mg>0 end
	local g=mg
	if #mg>1 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选择的怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
	-- 设置特殊召唤的操作信息（包含特殊召唤分类、目标卡片和数量）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（特殊召唤对象怪兽，并使其当作调整使用）
function c60306277.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并尝试将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理流程
	Duel.SpecialSummonComplete()
end
-- 效果③的发动条件（对方主要阶段）
function c60306277.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==1-tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果③的发动代价（把魔法与陷阱区域表侧表示的这张卡送去墓地）
function c60306277.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡作为发动代价送去墓地
	Duel.SendtoGrave(c,REASON_COST)
end
-- 效果③的发动准备（确认额外卡组是否存在可以进行同调召唤的怪兽，并设置特殊召唤的操作信息）
function c60306277.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在当前可以进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的效果处理（选择并进行1只同调怪兽的同调召唤）
function c60306277.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有当前可以进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要进行同调召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 让玩家对选定的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
