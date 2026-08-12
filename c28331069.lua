--超銀河眼の光子龍－フォトン・ハウリング
-- 效果：
-- 8星怪兽×3
-- 「超银河眼光子龙-光子咆哮」1回合1次也能在自己场上的8阶超量怪兽上面重叠来超量召唤。
-- ①：这张卡超量召唤的场合才能发动。从卡组选1只「光子」怪兽守备表示特殊召唤或作为这张卡的超量素材。
-- ②：自己·对方回合，把这张卡3个超量素材取除才能发动。自己场上1只其他的超量怪兽解放，这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括超量召唤手续、①超量召唤成功时从卡组选择「光子」怪兽特殊召唤或作为超量素材的效果、②去除3个素材并解放场上其他超量怪兽无效全场表侧表示卡效果的效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从卡组选1只「光子」怪兽守备表示特殊召唤或作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"是否在超量怪兽上面重叠来超量召唤？"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
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
-- 重叠超量召唤的素材过滤条件：自己场上表侧表示的8阶超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(8) and c:IsType(TYPE_XYZ)
end
-- 重叠超量召唤的次数限制注册：限制同名卡1回合只能通过重叠进行1次超量召唤
function s.xyzop(e,tp,chk)
	-- 检查本回合是否未进行过本卡重叠超量召唤
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 给玩家注册已进行过本卡重叠超量召唤的全局标识效果，持续到回合结束
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动条件：此卡是超量召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤卡组中符合条件的「光子」怪兽：必须是「光子」怪兽，且可以进行特殊召唤或者作为本卡的超量素材叠放
function s.filter(c,mc,e,tp)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER)
		-- 判断自己场上是否有空余的怪兽区域
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			or (mc and mc:IsType(TYPE_XYZ) and c:IsCanOverlay()))
end
-- ①效果的发动准备与目标检查（Target函数）：判断卡组是否存在合法的「光子」怪兽，并设定特殊召唤或从卡组送入超量的相关操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的「光子」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler(),e,tp) end
end
-- ①效果的处理（Operation函数）：从卡组选择1只满足条件的「光子」怪兽，选择进行守备表示特殊召唤或作为这张卡的超量素材叠放
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家提示：选择要处理的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"选择要处理的怪兽"
	-- 由发动效果的玩家从卡组选择1只满足过滤条件的「光子」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,aux.ExceptThisCard(e),e,tp)
	local tc=g:GetFirst()
	if tc then
		local ovchk=c:IsRelateToChain() and c:IsType(TYPE_XYZ) and tc:IsCanOverlay()
		-- 判断自己场上是否有空余怪兽区域，且该怪兽是否能守备表示特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			-- 若还可以作为超量素材，则由玩家选择是否进行特殊召唤
			and (not ovchk or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then  --"是否特殊召唤？"
			-- 将选择的「光子」怪兽以守备表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		elseif ovchk then
			-- 将该怪兽重叠在这张卡下作为超量素材
			Duel.Overlay(c,Group.FromCards(tc))
		end
	end
end
-- ②效果的发动代价（Cost函数）：检查并取除这张卡的3个超量素材
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- ②效果解放对象的过滤条件：自己场上其他的超量怪兽，如果启用对象检查，还需要场上存在可以被无效的其他表侧表示卡
function s.rsfilter(c,ec,tp,chk)
	local ng=Group.FromCards(c)
	if ec then ng:AddCard(ec) end
	return c:IsReleasableByEffect() and c:IsType(TYPE_XYZ)
		-- 若进行有效性检查，需要确认场上是否存在除要解放的怪兽和本卡以外的可被无效的卡
		and (not chk or Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ng))
end
-- ②效果的发动准备与目标检查（Target函数）：判断自己场上是否存在能被解放的其他超量怪兽，并设置无效卡片的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在满足解放条件的超量怪兽且场上有其他卡可被无效
	if chk==0 then return Duel.IsExistingMatchingCard(s.rsfilter,tp,LOCATION_MZONE,0,1,c,c,tp,true) end
	-- 获取场上除本卡以外所有满足被无效条件的卡片
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息为无效除本卡外场上所有卡片的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount()-1,0,0)
end
-- ②效果的处理（Operation函数）：选择自己场上1只其他的超量怪兽解放，使这张卡以外的场上全部表侧表示卡的效果直到回合结束时无效化
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示：选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=nil
	-- 获取与当前效果有关的本卡
	local ec=aux.ExceptThisCard(e)
	-- 判断自己场上是否存在满足解放条件且有其他无效目标的超量怪兽
	if Duel.IsExistingMatchingCard(s.rsfilter,tp,LOCATION_MZONE,0,1,ec,ec,tp,true) then
		-- 玩家选择自己场上1只可解放的超量怪兽
		rg=Duel.SelectMatchingCard(tp,s.rsfilter,tp,LOCATION_MZONE,0,1,1,ec,ec,tp,true)
	else
		-- 玩家在没有其他无效目标时依然可以选解放对象进行解放
		rg=Duel.SelectMatchingCard(tp,s.rsfilter,tp,LOCATION_MZONE,0,1,1,ec,ec,tp,false)
	end
	if not rg or rg:GetCount()==0 then return end
	-- 将选择的超量怪兽因效果解放，且成功解放
	if Duel.Release(rg,REASON_EFFECT)~=0 then
		-- 获取场上除本卡以外全部能够无效化效果的表侧表示卡
		local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 遍历所有需要无效化效果的卡片
		for tc in aux.Next(g) do
			-- 使与目标卡片相关的连锁都无效化
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
