--妖光のディアーブロッケン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方回合，从自己的场上（表侧表示）·墓地把1只炎属性怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
-- ③：这张卡作为连接素材送去墓地的场合才能发动。把这个回合被送去自己墓地的1张速攻魔法·通常陷阱卡从墓地到自己场上盖放。
local s,id,o=GetID()
-- 注册该卡的①②③三个效果：①从手卡特殊召唤、②特殊召唤时无效场上表侧卡、③作为连接素材时盖放本回合送去墓地的速攻魔法/通常陷阱；三个效果均带有1回合1次的次数限制。
function s.initial_effect(c)
	-- ①：自己·对方回合，从自己的场上（表侧表示）·墓地把1只炎属性怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为连接素材送去墓地的场合才能发动。把这个回合被送去自己墓地的1张速攻魔法·通常陷阱卡从墓地到自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- ①的cost筛选函数：判断一张卡是否满足作为发动代价的条件——炎属性、表侧表示、可除外，且将其除外后自己场上仍有可用怪兽区（为后续特殊召唤留出空位）。
function s.costfilter(c,tp)
	-- 筛选康慨：卡片为炎属性、处于表侧表示、可作为cost除外，并且该卡离开场上后己方怪兽区仍有空位。
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①的cost处理：先检查墓地/场上是否存在符合条件的炎属性怪兽；若有，则提示玩家选择1张要除外的卡，并将选择的卡表侧表示除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：确认自己墓地或场上表侧表示存在至少1张满足costfilter条件的炎属性怪兽，且除外后怪兽区有空位，效果才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送选择提示，显示“请选择要除外的卡”，用于接下来的除外选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的墓地或怪兽区选择1张满足costfilter的炎属性怪兽，作为发动①的cost所需除外的卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选择的那1张卡从墓地或场上表侧除外，作为发动这次的cost（COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①的目标检查与设定：确认这张卡自身可以被特殊召唤；若可以，则把本次效果信息登记为特殊召唤，准备将其特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：该效果属于特殊召唤类别，要特殊召唤的对象是本卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若这张卡仍然与当前连锁相关（未被除外或回到手牌等），则将其从手卡进行表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 实际执行特殊召唤：将这张卡以表侧表示特殊召唤到其持有者（当前玩家）的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②的发动目标确定：检查场上是否存在可无效的对象；若存在，则提示玩家选择1张表侧表示且可被无效的卡，锁定为对象，并设置无效化操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理中若已指定对象，则验证该对象卡是否仍在场上且满足可被无效的条件，作为取对象效果的合法性判定。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- ②发动条件检查：场上存在至少1张表侧表示且能被无效的卡，才能以该效果选择对象并发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示，显示“请选择要无效的卡”，用于接下来的对象选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从双方场上选择1张满足aux.NegateAnyFilter的卡作为②的效果对象，并将其锁定为该连锁的对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：该效果属于无效化类别，已选择1张对象卡，用于后续的无效处理。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②的效果处理：对作为对象的场上表侧表示卡执行无效化——使其相关连锁效果无效、其卡的效果无效、其效果发动无效，若对象是陷阱怪兽则额外进行陷阱怪兽无效处理，直到回合结束时有效。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理中储存的对象卡，即之前选择的场上表侧表示的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与对象卡相关的连锁效果无效化，持续到回合结束。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ②：那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- ②：那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- ②：那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- ③的发动条件：这张卡作为连接素材被送去墓地时，且此时这张卡位于墓地，效果才能发动（r==REASON_LINK表示因连接素材而送去墓地）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- ③的检索过滤函数：筛选出本回合被送去自己墓地的速攻魔法或通常陷阱卡，且它们可以被盖放，并且不是因为返回手牌等特殊原因进入墓地的卡。
function s.setfilter(c)
	-- 筛选条件：该卡被送去墓地的回合编号等于当前回合数（即本回合内被送去墓地），类型为速攻魔法或通常陷阱（仅通常陷阱），并且当前规则下可以盖放。
	return c:GetTurnID()==Duel.GetTurnCount() and (c:IsType(TYPE_QUICKPLAY) or c:GetType()==TYPE_TRAP) and c:IsSSetable()
		and not c:IsReason(REASON_RETURN)
end
-- ③的发动目标确定：从自己墓地中获取所有满足条件的卡，若存在1张或以上则可发动，并设置效果类别为“离开墓地”（CATEGORY_LEAVE_GRAVE）。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有满足s.setfilter条件的卡，作为本次盖放效果的可选集合。
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：效果会使卡离开墓地，目标组为所有符合条件的墓地卡，数量设为1张，供后续处理时使用。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③的效果处理：提示玩家选择1张符合条件的墓地卡，在不受王家长眠之谷影响的条件下选择1张，并将其里侧表示盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示，显示“请选择要盖放的卡”，用于接下来的盖放选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地中选择1张满足s.setfilter且不受王家长眠之谷影响的卡，作为要盖放的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片以里侧表示盖放到自己魔法与陷阱区域，完成③的盖放处理。
		Duel.SSet(tp,g:GetFirst())
	end
end
