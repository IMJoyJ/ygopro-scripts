--アザミナ・ハマルティア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的自己的墓地·除外状态的「罪宝」卡回到卡组。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
local s,id,o=GetID()
-- 初始化函数：注册①效果（魔法发动型的自由时点效果，分类包含墓地移动·特殊召唤·融合召唤·回卡组，与②效果共用1回合1次的次数限制）和②效果（墓地发动的诱发即时效果，取对象，代价是除外这张卡，分类为盖放魔法·陷阱卡）。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能有1次使用其中任意1个。①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的自己的墓地·除外状态的「罪宝」卡回到卡组。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_GRAVE_ACTION+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将除外墓地的这张卡设定为②效果的发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 融合怪兽的过滤条件：必须是等级4以上的「蓟花」融合怪兽、有登记融合素材、可以当作融合召唤特殊召唤，并且能从墓地·除外的「罪宝」卡中选出数量等于其等级除以4的组合作为返回卡组的卡。
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 检查选出的卡片组合是否满足条件：让这些卡离场后有可以特殊召唤额外卡组怪兽的怪兽区域空格，且组合中所有卡都能回到卡组。
function s.gcheck(g,tp,fc)
	-- 确认这些卡离开墓地·除外状态后，场上仍有能将额外卡组的融合怪兽特殊召唤的空位。
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToDeck,nil)==g:GetCount()
end
-- ①效果的发动条件检测：确认不存在必须成为融合素材的限制冲突，且额外卡组存在满足条件的可特殊召唤的「蓟花」融合怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己墓地以及除外状态的表侧表示「罪宝」卡作为候选。
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.IsFaceupEx),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 检测玩家是否受到必须成为融合素材的效果影响（若有则可能影响此效果的正常处理）。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检测额外卡组是否存在至少1只满足过滤条件、可以特殊召唤的「蓟花」融合怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息：宣言此效果将从额外卡组特殊召唤1只怪兽（具体卡在效果处理时才确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理：先检查融合素材限制，再取得墓地·除外状态的「罪宝」卡，让玩家选1只要给人观看并特殊召唤的「蓟花」融合怪兽，给对方确认后按其等级每4星选1张「罪宝」卡回到卡组，那之后把给人观看的怪兽当作融合召唤作特殊召唤并完成召唤手续。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认没有必须成为融合素材的限制冲突，有则中断处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 取得自己墓地以及除外状态的不受「王家长眠之谷」影响的表侧表示「罪宝」卡作为候选。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.AND(Card.IsSetCard,Card.IsFaceupEx)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「蓟花」融合怪兽（即要给对方观看的怪兽）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 把选择的融合怪兽给对方观看（确认）。
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择要回到卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		if sg:GetCount()>0 then
			-- 显示选中的要回到卡组的卡的提示动画，并记录这些卡被选择。
			Duel.HintSelection(sg)
			-- 将选择的「罪宝」卡洗回卡组，并确认它们确实回到了卡组或额外卡组。
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=0 then
				-- 中断当前效果处理，使之后的特殊召唤与前面的回卡组视为不同时处理（避免同时处理的时点问题）。
				Duel.BreakEffect()
				tc:SetMaterial(nil)
				-- 把给人观看的怪兽当作融合召唤作特殊召唤（表侧表示）。
				if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end
end
-- 盖放对象的过滤条件：是可以盖放在自己场上的「罪宝」魔法·陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的对象选择与发动条件检测：确认自己墓地存在可成为对象的「罪宝」魔法·陷阱卡，让玩家选择其中1张作为对象，并设置该卡将离开墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检测自己墓地是否存在至少1张能成为对象的「罪宝」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家选择自己墓地1张「罪宝」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：宣言作为对象的卡将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的处理：取得对象卡，若其仍与效果关联且不受「王家长眠之谷」影响，则在自己场上盖放，并给那张卡加上这个回合不能发动的限制。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象卡（即选择的那张「罪宝」魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与这个效果关联、不受「王家长眠之谷」影响，并将其在自己场上盖放成功。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在这个回合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
