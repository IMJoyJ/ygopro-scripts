--超銀河眼の光子龍－フォトン・ハウリング
-- 效果：
-- 8星怪兽×3
-- 「超银河眼光子龙-光子咆哮」1回合1次也能在自己场上的8阶超量怪兽上面重叠来超量召唤。
-- ①：这张卡超量召唤的场合才能发动。从卡组选1只「光子」怪兽守备表示特殊召唤或作为这张卡的超量素材。
-- ②：自己·对方回合，把这张卡3个超量素材取除才能发动。自己场上1只其他的超量怪兽解放，这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
local s,id,o=GetID()
-- 初始化卡片效果，注册「8星怪兽×3」及「1回合1次也能在自己场上的8阶超量怪兽上面重叠来超量召唤」的超量召唤手续，以及①②效果。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 「超银河眼光子龙-光子咆哮」1回合1次也能在自己场上的8阶超量怪兽上面重叠来超量召唤。①：这张卡超量召唤的场合才能发动。从卡组选1只「光子」怪兽守备表示特殊召唤或作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"是否在超量怪兽上面重叠来超量召唤？"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡3个超量素材取除才能发动。自己场上1只其他的超量怪兽解放，这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 叠光超量召唤的素材过滤函数：检查怪兽是否为自己场上的表侧表示8阶超量怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(8) and c:IsType(TYPE_XYZ)
end
-- 叠光超量召唤的1回合1次限制函数：检查并记录本回合已使用过「超银河眼光子龙-光子咆哮」的叠光召唤方式。
function s.xyzop(e,tp,chk)
	-- 检查己方本回合是否尚未使用过「超银河眼光子龙-光子咆哮」的叠光超量召唤。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为己方注册持续到回合结束的誓约标识，限制本回合不能再次以此方式叠光召唤。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动条件：检查这张卡是否是以超量召唤的方式特殊召唤成功的。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤条件：检查卡片是否为可守备表示特殊召唤或可作为超量素材重叠的「光子」怪兽。
function s.filter(c,mc,e,tp)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER)
		-- 判断自己主要怪兽区是否存在可用于特殊召唤的空位。
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			or (mc and mc:IsType(TYPE_XYZ) and c:IsCanOverlay()))
end
-- ①效果的目标处理函数：检查自己卡组是否存在可特殊召唤或作为超量素材的「光子」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组存在至少1只符合条件的「光子」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler(),e,tp) end
end
-- ①效果的处理函数：从卡组选1只「光子」怪兽，根据条件或玩家选择守备表示特殊召唤或作为这张卡的超量素材。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发送提示信息，引导玩家选择要处理的「光子」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"选择要处理的怪兽"
	-- 从自己卡组选择1只满足条件的「光子」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,aux.ExceptThisCard(e),e,tp)
	local tc=g:GetFirst()
	if tc then
		local ovchk=c:IsRelateToChain() and c:IsType(TYPE_XYZ) and tc:IsCanOverlay()
		-- 检查自己怪兽区是否有空位且所选怪兽可以被守备表示特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			-- 若无法作为超量素材或玩家选择特殊召唤，则执行特殊召唤分支。
			and (not ovchk or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then  --"是否特殊召唤？"
			-- 将所选「光子」怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		elseif ovchk then
			-- 将所选「光子」怪兽作为超量素材重叠到这张卡下面。
			Duel.Overlay(c,Group.FromCards(tc))
		end
	end
end
-- ②效果的发动代价：检查并从这张卡取除3个超量素材作为发动代价。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 过滤条件：检查怪兽是否为可被效果解放的其他超量怪兽，且在解放后场上仍存在其他可被无效的表侧表示卡。
function s.rsfilter(c,ec,tp,chk)
	local ng=Group.FromCards(c)
	if ec then ng:AddCard(ec) end
	return c:IsReleasableByEffect() and c:IsType(TYPE_XYZ)
		-- 检查解放该超量怪兽后，双方场上除这张卡与被解放怪兽外是否仍存在可被无效的表侧表示卡。
		and (not chk or Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ng))
end
-- ②效果的目标处理函数：检查自己场上是否存在可解放的其他超量怪兽，并设置全场效果无效的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：确认自己怪兽区存在至少1只满足条件的其他超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rsfilter,tp,LOCATION_MZONE,0,1,c,c,tp,true) end
	-- 获取双方场上除自身外所有可被无效的表侧表示卡片组。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息：预计使场上除自身及待解放怪兽外的表侧表示卡效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount()-1,0,0)
end
-- ②效果的处理函数：解放自己场上1只其他超量怪兽，随后使自身以外场上全部表侧表示卡效果直到回合结束时无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，引导玩家选择要解放的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=nil
	-- 判断这张卡是否仍与当前连锁相关联，若是则返回这张卡自身以便排除。
	local ec=aux.ExceptThisCard(e)
	-- 检查解放该怪兽后场上是否仍存在其他可被无效的表侧表示卡。
	if Duel.IsExistingMatchingCard(s.rsfilter,tp,LOCATION_MZONE,0,1,ec,ec,tp,true) then
		-- 若存在解放后仍有可无效卡片的选项，从中选择1只自己的其他超量怪兽。
		rg=Duel.SelectMatchingCard(tp,s.rsfilter,tp,LOCATION_MZONE,0,1,1,ec,ec,tp,true)
	else
		-- 若已无符合后续可无效卡片的解放选项，则退而选择任意1只自己的其他可效果解放的超量怪兽。
		rg=Duel.SelectMatchingCard(tp,s.rsfilter,tp,LOCATION_MZONE,0,1,1,ec,ec,tp,false)
	end
	if not rg or rg:GetCount()==0 then return end
	-- 以效果解放所选的己方超量怪兽，并判断是否解放成功。
	if Duel.Release(rg,REASON_EFFECT)~=0 then
		-- 获取当前双方场上除自身外所有可被无效的表侧表示卡片组。
		local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 遍历所有需要被无效效果的卡片。
		for tc in aux.Next(g) do
			-- 使与当前遍历卡片相关的连锁效果无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
