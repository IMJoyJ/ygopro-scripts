--巳剣大祓
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：对方把魔法·陷阱·怪兽的效果发动时，把自己场上1只5星以上的爬虫类族怪兽解放才能发动。那个效果无效并破坏。
-- ②：把墓地的这张卡除外，以自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤，这个效果特殊召唤的怪兽以外的自己场上1只怪兽解放。
local s,id,o=GetID()
-- 创建并注册①和②两个效果：①作为魔法·陷阱卡发动，响应对方发动魔法·陷阱·怪兽效果，解放自己场上1只5星以上爬虫类族怪兽为代价，无效并破坏那个效果；②为墓地快速效果，除外自身并以自己墓地1只爬虫类族怪兽为对象特殊召唤，再解放自己场上另1只怪兽。两个效果共用1回合1次的发动次数。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：对方把魔法·陷阱·怪兽的效果发动时，把自己场上1只5星以上的爬虫类族怪兽解放才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤，这个效果特殊召唤的怪兽以外的自己场上1只怪兽解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置②效果的发动代价：将墓地中的这张卡除外。aux.bfgcost为预定义的代价辅助函数，负责在代价判定时检查可除外并在发动时实际除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件函数：只在对方发动魔法·陷阱·怪兽效果，且该效果可以被无效时，才允许发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：效果发动者不是自己（即对方发动）且连锁中的该效果能够被无效。
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 可解放素材的过滤条件：爬虫类族、5星以上，且不是战斗破坏确定状态的怪兽。
function s.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsLevelAbove(5) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ①效果的代价处理：先检查自己场上是否存在满足条件的解放素材；若有，则选择1只爬虫类族5星以上怪兽解放作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认自己场上存在至少1只可解放的爬虫类族5星以上怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) end
	-- 从自己场上选择1只满足解放条件的怪兽作为代价素材。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil)
	-- 解放所选怪兽，解放原因为COST，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- ①效果的目标/操作信息处理：不取对象，target始终返回true；写入无效对方效果的操作信息，若对方效果卡可破坏且仍关联，则追加破坏操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 写入操作信息：将无效连锁中的效果，目标为对方发动效果相关的卡（eg），数量1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方效果卡的持有者卡可被破坏且仍与效果关联，则追加破坏该卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理①效果：先使对方发动的效果无效，若成功且对方效果卡仍关联，则破坏该卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：Duel.NegateEffect(ev)返回成功（效果被无效）且效果卡仍与效果关联，才进行破坏。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方发动效果的那张卡（eg），破坏原因为效果。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②效果特殊召唤对象的过滤条件：墓地中的爬虫类族怪兽，并且可以被当前效果特殊召唤（满足召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择与发动合法性检查：选择自己墓地1只爬虫类族怪兽为对象；要求自己主要怪兽区有空位，且自己场上存在可解放怪兽。chkc参数用于系统验证已选对象是否合法。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己场上主要怪兽区存在空位，可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在1只符合条件的爬虫类族怪兽（排除自身，因为自身除外作为代价）可供选择为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp)
		-- 发动条件之三：自己场上存在至少1只可被效果解放的怪兽，用于特殊召唤后解放。
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合spfilter的爬虫类族怪兽，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 写入操作信息：本次效果处理包含特殊召唤，对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理②效果：取得对象卡，若仍与效果关联则将其特殊召唤；特殊召唤成功后，选择自己场上1只除该怪兽以外的可解放怪兽并解放。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中的对象卡（被选为特殊召唤对象的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍与效果关联，且以表侧表示特殊召唤成功（返回值不等于0）时，才继续后续解放处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 弹出选择提示，提示玩家选择要解放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择自己场上1只除特殊召唤怪兽（tc）以外的、可被效果解放的怪兽，位置限定主要怪兽区。
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,1,1,tc)
		if g:GetCount()>0 then
			-- 显示被选择解放的卡的选中动画，并记录其被效果选取。
			Duel.HintSelection(g)
			-- 解放所选怪兽，解放原因为效果。
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
