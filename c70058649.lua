--道化の一座『怪演』
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
-- ●从卡组·额外卡组把最多2只「道化一座」怪兽无视召唤条件特殊召唤。
-- ●从卡组把1只「道化一座」怪兽加入手卡。
-- ②：自己·对方的主要阶段，把墓地的这张卡除外才能发动。表侧表示进行1只「道化一座」怪兽的上级召唤。
local s,id,o=GetID()
-- 注册卡片效果：①效果（卡片发动时的效果选择）和②效果（墓地除外进行上级召唤）。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把墓地的这张卡除外才能发动。表侧表示进行1只「道化一座」怪兽的上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上级召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.sumcon)
	-- 设置发动Cost为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组·额外卡组中可以特殊召唤的「道化一座」怪兽，且自身场上有可用的怪兽区域。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
		-- 若卡片在卡组，则需要自己场上有可用的怪兽区域。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若卡片在额外卡组，则需要自己场上有可用的额外怪兽区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 过滤条件：卡组中可以加入手卡的「道化一座」怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备：检测可发动的分支效果，并让玩家选择其中一个分支，注册对应的同名卡回合限制标记并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·额外卡组是否存在可特殊召唤的「道化一座」怪兽。
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 检查本回合是否尚未选择过特殊召唤的分支效果。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查卡组是否存在可加入手卡的「道化一座」怪兽。
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查本回合是否尚未选择过加入手卡的分支效果。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可用的分支效果中选择一个发动。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"加入手卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 给玩家注册已选择特殊召唤分支的标记，持续到回合结束。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置特殊召唤的操作信息（从卡组·额外卡组特殊召唤1只怪兽）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
			-- 给玩家注册已选择加入手卡分支的标记，持续到回合结束。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置检索的操作信息（从卡组将1张卡加入手卡）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 过滤条件：额外卡组中表侧表示的灵摆怪兽或连接怪兽。
function s.filter(c)
	return (c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		or c:IsType(TYPE_LINK))
		and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：存在于额外卡组的卡。
function s.filter2(c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 组过滤条件：确保从额外卡组特殊召唤的怪兽数量不超过可用额外怪兽区域数量。
function s.gcheck(g,tp,eft,ect)
	return g:FilterCount(s.filter,nil)<=eft and g:FilterCount(s.filter2,nil)<=ect
end
-- ①效果的处理：根据选择的分支执行特殊召唤或加入手卡，并适用“不能把从卡组·额外卡组特殊召唤的怪兽的效果发动”的限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取自己场上可用的怪兽区域数量。
		local ft=Duel.GetUsableMZoneCount(tp)
		-- 获取自己场上可用于特殊召唤额外卡组灵摆怪兽的区域数量。
		local eft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
		if ft>0 then
			if ft>=2 then ft=2 end
			local ct=2
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 考虑额外卡组特殊召唤限制后，计算可从额外卡组特殊召唤的怪兽数量上限。
			local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
			local loc=LOCATION_DECK
			if ect>0 then loc=loc+LOCATION_EXTRA end
			-- 获取卡组·额外卡组中所有满足特殊召唤条件的「道化一座」怪兽。
			local g=Duel.GetMatchingGroup(s.spfilter,tp,loc,0,nil,e,tp)
			if g:GetCount()>0 then
				-- 提示玩家选择要特殊召唤的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:SelectSubGroup(tp,s.gcheck,false,1,ct,tp,eft,ect)
				if sg:GetCount()>0 then
					local exg=sg:Filter(s.filter,nil)
					sg:Sub(exg)
					if exg:GetCount()>0 then
						-- 遍历需要从额外卡组特殊召唤的灵摆/连接怪兽。
						for tc in aux.Next(exg) do
							-- 逐步特殊召唤该怪兽（无视召唤条件，表侧表示）。
							Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
						end
					end
					local exg2=sg:Filter(s.filter2,nil)
					sg:Sub(exg2)
					if exg2:GetCount()>0 then
						-- 遍历需要从额外卡组特殊召唤的其他怪兽。
						for tc in aux.Next(exg2) do
							-- 逐步特殊召唤该额外卡组怪兽（无视召唤条件，表侧表示）。
							Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
						end
					end
					if sg:GetCount()>0 then
						-- 遍历需要从主卡组特殊召唤的怪兽。
						for tc in aux.Next(sg) do
							-- 逐步特殊召唤该主卡组怪兽（无视召唤条件，表侧表示）。
							Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
						end
					end
					-- 完成所有怪兽的特殊召唤处理。
					Duel.SpecialSummonComplete()
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只「道化一座」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。/②：自己·对方的主要阶段，把墓地的这张卡除外才能发动。表侧表示进行1只「道化一座」怪兽的上级召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册限制玩家发动效果的全局效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能发动从卡组·额外卡组特殊召唤的怪兽的效果。
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的发动条件：自己或对方的主要阶段。
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 过滤条件：手卡中可以进行上级召唤的「道化一座」怪兽。
function s.sumfilter(c)
	return c:IsSetCard(0x1dc) and c:IsSummonable(true,nil,1)
end
-- ②效果的发动准备：检查手卡中是否存在可上级召唤的「道化一座」怪兽，并设置召唤的操作信息。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以进行上级召唤的「道化一座」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置通常召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果的处理：让玩家选择手卡中的1只「道化一座」怪兽进行上级召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡选择1只满足上级召唤条件的「道化一座」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 进行1只怪兽的上级召唤（表侧表示通常召唤，需要1个祭品）。
		Duel.Summon(tp,tc,true,nil,1)
	end
end
