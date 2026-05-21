--白き森のあくま
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只同调怪兽解放，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。把「白森林」同调怪兽解放发动的场合，可以再从自己墓地把1只幻想魔族怪兽特殊召唤。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（无效场上卡片/特召墓地幻想魔族）和②效果（因怪兽效果发动送墓则自身盖放）。
function s.initial_effect(c)
	-- ①：把自己场上1只同调怪兽解放，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。把「白森林」同调怪兽解放发动的场合，可以再从自己墓地把1只幻想魔族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于解放的同调怪兽（必须在自己场上，或者在场上表侧表示），且场上存在至少1张其他可无效的卡。
function s.costfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查场上是否存在至少1张除了该解放怪兽以外的、可作为无效化对象的表侧表示卡片。
		and Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- ①效果的发动代价（Cost）处理函数：解放自己场上1只同调怪兽，并记录是否解放了「白森林」同调怪兽。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 步骤0：检查自己场上是否存在可作为解放代价的同调怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足条件的同调怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,tp)
	if g:GetFirst():IsSetCard(0x1b1) then e:SetLabel(100) end
	-- 将选中的怪兽解放。
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：场上表侧表示且可以被无效效果的卡。
function s.negfilter(c)
	-- 判定卡片是否为表侧表示且符合无效化效果的目标条件。
	return c:IsFaceup() and aux.NegateAnyFilter(c)
end
-- 过滤函数：墓地中可以特殊召唤的幻想魔族怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的目标选择（Target）处理函数：选择场上1张表侧表示卡为对象，若满足追加特召条件则更新效果分类。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local l=e:GetLabel()
	if chkc then return chkc:IsOnField() and s.negfilter(chkc) and c~=chkc end
	-- 步骤0：检查场上是否存在可作为无效化对象的表侧表示卡片。
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择1张表侧表示卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置连锁信息：包含无效卡片效果的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	if l==100 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	end
end
-- ①效果的效果处理（Operation）函数：使对象卡的效果无效，若解放的是「白森林」同调怪兽，则可再从墓地特召1只幻想魔族怪兽。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local l=e:GetLabel()
	-- 获取作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该对象卡相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		-- 立即刷新场上卡片的无效状态。
		Duel.AdjustInstantly()
		-- 检查是否满足追加效果条件（解放了「白森林」同调怪兽）且自己场上有空余的怪兽区域。
		if l==100 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己墓地是否存在可特殊召唤的幻想魔族怪兽（受王家之谷影响）。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 询问玩家是否选择发动追加的特殊召唤效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从墓地选择1只幻想魔族怪兽。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续的特殊召唤处理与无效处理不视为同时进行。
				Duel.BreakEffect()
				-- 将选中的幻想魔族怪兽在自己场上表侧表示特殊召唤。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- ②效果的发动条件（Condition）函数：这张卡作为怪兽效果发动的代价（Cost）被送去墓地的场合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的目标选择（Target）处理函数：检查自身是否可以盖放，并设置连锁信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置连锁信息：包含卡片离开墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果的效果处理（Operation）函数：将墓地的这张卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其在自己场上盖放。
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
