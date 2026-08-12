--久遠の神徒フリムニル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的手卡·场上3只天使族怪兽解放才能发动。从卡组把1张永续魔法卡在自己场上盖放。这个效果盖放的卡在对方结束阶段送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册①效果（起动效果，解放3只天使族怪兽从卡组盖放永续魔法）和②效果（被效果送去墓地时诱发特殊召唤），均1回合1次。
function s.initial_effect(c)
	-- ①：把自己的手卡·场上3只天使族怪兽解放才能发动。从卡组把1张永续魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：满足可解放、种族为天使族，且为自己控制（手卡）或表侧表示（场上）的怪兽。
function s.filter(c,tp)
	return c:IsReleasable() and c:IsRace(RACE_FAIRY) and (c:IsControler(tp) or c:IsFaceup())
end
-- 子组校验函数：检查解放该组合后魔法陷阱区仍有空位，且组合中所有卡都能作为代价解放。
function s.rcheck(g,tp)
	-- 检查解放这组卡后自己魔法陷阱区还有空格，并检查组内卡均可作为代价解放（考虑代替解放效果）。
	return Duel.GetSZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,Auxiliary.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- 代价处理函数：从自己手卡·场上的可解放天使族怪兽中选出满足条件的3只，作为发动代价解放。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己可解放（含手卡）的卡片组，再过滤出满足条件的天使族怪兽，作为候选解放组合。
	local rg=Duel.GetReleaseGroup(tp,true,REASON_COST):Filter(s.filter,nil,tp)
	if chk==0 then return rg:CheckSubGroup(s.rcheck,3,3,tp) end
	-- 向玩家发出「请选择要解放的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local g=rg:SelectSubGroup(tp,s.rcheck,false,3,3,tp)
	-- 消耗组合中代替解放类效果（如暗影敌托邦）的使用次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 把选出的3只怪兽作为代价解放。
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：是永续魔法卡且可以盖放的卡。
function s.stfilter(c)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL) and c:IsSSetable()
end
-- 目标检查函数：确认魔法陷阱区有空位，且卡组存在1张以上可盖放的永续魔法卡。
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己魔法陷阱区有空格，且卡组存在满足条件的永续魔法卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选1张永续魔法卡在自己场上盖放，并为其注册在对方结束阶段送去墓地的持续处理效果。
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己魔法陷阱区没有空格则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家发出「请选择要盖放的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的永续魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选出的永续魔法卡在自己场上盖放。
		local ct=Duel.SSet(tp,g)
		if ct~=0 then
			local tc=g:GetFirst()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			-- 这个效果盖放的卡在对方结束阶段送去墓地。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.tgcon)
			e1:SetOperation(s.tgop)
			-- 把「对方结束阶段送去墓地」的持续效果注册为玩家的全局环境效果。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 条件检查：仅在对方结束阶段、且被标记的卡仍为这个效果记录的盖放卡时成立；否则重置该效果并不再处理。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是对方（即处于对方结束阶段），否则不成立。
	if Duel.GetTurnPlayer()~=1-tp then return false end
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 处理函数：把记录的盖放卡以效果原因送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将该盖放卡送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
-- 发动条件：这张卡是被效果（含因效果代替）送去墓地的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT+REASON_REDIRECT)
end
-- 目标检查函数：确认自己怪兽区有空位，且这张卡可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己主要怪兽区有空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：宣告将特殊召唤这张卡（供星尘龙等效果的发动检测使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：把这张卡从墓地特殊召唤，并赋予其「从场上离开的场合除外」的永续效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与该连锁关联、且不受王家长眠之谷影响，则将其表侧表示特殊召唤到自己场上。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
