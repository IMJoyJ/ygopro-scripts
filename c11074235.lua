--魔晶龍ジルドラス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的魔法·陷阱卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地的卡以及除外的自己的卡之中选1张魔法·陷阱卡在自己的魔法与陷阱区域盖放。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c11074235.initial_effect(c)
	-- 创建一个诱发选发效果，当自己场上的魔法·陷阱卡因对方的效果从场上离开送去墓地或除外时发动，将此卡特殊召唤。
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
-- 过滤函数，用于判断被送去墓地或除外的卡是否为魔法·陷阱卡且为己方场上离开的卡。
function c11074235.cfilter(c,tp)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_SPELL+TYPE_TRAP)~=0 and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 效果发动条件，判断是否有满足条件的魔法·陷阱卡因对方效果从场上离开。
function c11074235.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11074235.cfilter,1,nil,tp)
end
-- 效果处理目标设定，判断是否可以特殊召唤此卡。
function c11074235.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段，判断场上是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，确定特殊召唤的卡为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于筛选可盖放的魔法·陷阱卡。
function c11074235.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSSetable()
end
-- 效果处理函数，执行特殊召唤及后续盖放魔法·陷阱卡的操作。
function c11074235.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤后此卡离场时除外的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 获取自己墓地和除外区中满足条件的魔法·陷阱卡。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c11074235.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 判断是否有可盖放的魔法·陷阱卡并询问玩家是否盖放。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(11074235,1)) then  --"是否盖放魔法·陷阱卡？"
			-- 中断当前效果处理，使后续处理视为不同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的魔法·陷阱卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的魔法·陷阱卡盖放到玩家的魔法与陷阱区域。
			Duel.SSet(tp,sg)
		end
	end
end
