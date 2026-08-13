--魔晶龍ジルドラス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的魔法·陷阱卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地的卡以及除外的自己的卡之中选1张魔法·陷阱卡在自己的魔法与陷阱区域盖放。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c11074235.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，自己场上的魔法·陷阱卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地的卡以及除外的自己的卡之中选1张魔法·陷阱卡在自己的魔法与陷阱区域盖放。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11074235,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,11074235)
	e1:SetCondition(c11074235.spcon)
	e1:SetTarget(c11074235.sptg)
	e1:SetOperation(c11074235.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
end
-- 筛选因对方效果从场上离开的魔法·陷阱卡：该卡离场前是魔法·陷阱卡、之前的控制者是己方、离场前位于场上、离场原因是对方的效果。
function c11074235.cfilter(c,tp)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_SPELL+TYPE_TRAP)~=0 and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 发动条件的判定：这次被送去墓地/除外的卡组中存在至少1张满足cfilter条件的卡，即存在自己的魔法·陷阱卡因对方效果从场上离场。
function c11074235.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11074235.cfilter,1,nil,tp)
end
-- 发动时点检查：自己主要怪兽区有空位，且这张卡本身可以被玩家tp特殊召唤。
function c11074235.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区来特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果处理将进行特殊召唤，对象为效果持有者（这张卡），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义可盖放卡牌的筛选条件：是魔法·陷阱卡，不是场地魔法卡，且是墓地中的卡或表侧表示的除外卡，并且满足可以盖放到魔陷区的条件。
function c11074235.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSSetable()
end
-- 效果处理：先确认此卡仍与效果关联，然后将其特殊召唤；若特殊召唤成功，给此卡附加离场时改为除外的效果；随后从符合条件的自己墓地/除外区的魔陷中选1张盖放到自己的魔陷区。
function c11074235.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤，返回特殊召唤成功的数量；若成功则继续后续处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。那之后，可以从自己墓地的卡以及除外的自己的卡之中选1张魔法·陷阱卡在自己的魔法与陷阱区域盖放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 从自己的墓地与除外区中，筛选出满足setfilter条件的卡（不受王家长眠之谷等效果影响的卡）。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c11074235.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 若存在可选盖放的卡，则询问玩家是否要盖放；玩家选择是时继续执行。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(11074235,1)) then  --"是否盖放魔法·陷阱卡？"
			-- 中断当前效果处理，使后续盖放处理视为不同时点处理，避免引起时点问题。
			Duel.BreakEffect()
			-- 向玩家显示卡片选择提示，提示内容为“请选择要盖放的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡片盖放到玩家自己的魔法与陷阱区域。
			Duel.SSet(tp,sg)
		end
	end
end
