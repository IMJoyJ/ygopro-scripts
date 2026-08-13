--幻創のミセラサウルス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把这张卡从手卡送去墓地才能发动。这次主要阶段中，自己场上的恐龙族怪兽不受对方发动的效果影响。
-- ②：从自己墓地把包含这张卡的恐龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只恐龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c38572779.initial_effect(c)
	-- ①：自己·对方的主要阶段，把这张卡从手卡送去墓地才能发动。这次主要阶段中，自己场上的恐龙族怪兽不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38572779,0))  --"免疫效果"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38572779.immcon)
	e1:SetCost(c38572779.immcost)
	e1:SetTarget(c38572779.immtg)
	e1:SetOperation(c38572779.immop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：从自己墓地把包含这张卡的恐龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只恐龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38572779,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,38572779)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c38572779.spcost)
	e2:SetTarget(c38572779.sptg)
	e2:SetOperation(c38572779.spop)
	c:RegisterEffect(e2)
end
-- 发动条件：当前阶段为主要阶段1或主要阶段2，即只能在主要阶段发动此效果。
function c38572779.immcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 代价判定：将这张卡从手卡送去墓地作为发动代价；非判定时执行送墓。
function c38572779.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送入墓地（作为代价）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 目标条件：当前玩家没有38572779标记，即本次主要阶段还未发动过此免疫效果。
function c38572779.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：当前玩家不存在38572779标记（主要阶段内尚未发动过该效果）时可通过。
	if chk==0 then return Duel.GetFlagEffect(tp,38572779)==0 end
end
-- 效果处理：为当前玩家场上的恐龙族怪兽创建一个免疫效果，使其不受对方发动的效果影响；该效果持续到当前主要阶段结束，同时为该玩家登记本次主要阶段已使用过此效果的标记。
function c38572779.immop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：从自己墓地把包含这张卡的恐龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只恐龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置免疫效果适用的对象：自己场上所有恐龙族怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DINOSAUR))
	e1:SetValue(c38572779.efilter)
	-- 判断当前处于主要阶段1还是主要阶段2，以设置对应重置阶段。
	if Duel.GetCurrentPhase()==PHASE_MAIN1 then
		e1:SetReset(RESET_PHASE+PHASE_MAIN1)
		-- 为当前玩家登记38572779标记，该标记在主要阶段1结束时重置，用于限制本次主要阶段内该效果只能发动一次。
		Duel.RegisterFlagEffect(tp,38572779,RESET_PHASE+PHASE_MAIN1,0,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_MAIN2)
		-- 为当前玩家登记38572779标记，该标记在主要阶段2结束时重置，用于限制本次主要阶段内该效果只能发动一次。
		Duel.RegisterFlagEffect(tp,38572779,RESET_PHASE+PHASE_MAIN2,0,1)
	end
	-- 将免疫效果注册到当前玩家场上（以tp控制者为对象），开始生效。
	Duel.RegisterEffect(e1,tp)
end
-- 免疫判定：仅免疫由对方玩家发动的且已经被激活的效果（非永续等非发动效果）。
function c38572779.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 发动代价的预处理：将效果标签设为100，表示进入代价选择流程（实际除外在目标选择阶段完成）。
function c38572779.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选可作为代价除外的卡：恐龙族怪兽且能够被除外作为代价。
function c38572779.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 筛选卡组中可作为特殊召唤候选的恐龙族怪兽：必须为恐龙族、等级不高于当前墓地可除外的恐龙族数量、并且能够被特殊召唤。
function c38572779.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标处理：计算墓地可除外的恐龙族数量，让玩家宣言特殊召唤怪兽的等级（=除外数量），随后从墓地选择该数量减1张恐龙族怪兽连同本卡一起除外，并将卡组特殊召唤的操作信息登记到连锁。
function c38572779.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 获取我方墓地中所有可作为代价除外的恐龙族怪兽组（用于计算可选数量与作为除外候选）。
		local cg=Duel.GetMatchingGroup(c38572779.cfilter,tp,LOCATION_GRAVE,0,nil)
		return c:IsAbleToRemoveAsCost()
			-- 检查我方主要怪兽区是否有空位，保证特殊召唤可以进行。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在至少1只等级不超过墓地可除外恐龙数量且能够被特殊召唤的恐龙族怪兽，以确认效果可以发动。
			and Duel.IsExistingMatchingCard(c38572779.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,cg:GetCount())
	end
	-- 再次获取墓地可除外的恐龙族怪兽组，用于后续选择除外牌。
	local cg=Duel.GetMatchingGroup(c38572779.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取卡组中满足初筛条件（恐龙族、等级≤墓地可除外恐龙数、可特殊召唤）的候选怪兽组。
	local tg=Duel.GetMatchingGroup(c38572779.spfilter,tp,LOCATION_DECK,0,nil,e,tp,cg:GetCount())
	local lvt={}
	local tc=tg:GetFirst()
	while tc do
		local tlv=0
		tlv=tlv+tc:GetLevel()
		lvt[tlv]=tlv
		tc=tg:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家需要选择要特殊召唤的怪兽等级，将选择消息写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38572779,2))  --"请选择要特殊召唤的怪兽的等级"
	-- 让玩家宣言一个等级（从可选的等级列表中），返回宣言的等级。
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	local rg1=Group.CreateGroup()
	if lv>1 then
		-- 提示玩家选择要除外的恐龙族卡片（作为代价的一部分）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg2=cg:Select(tp,lv-1,lv-1,c)
		rg1:Merge(rg2)
	end
	rg1:AddCard(c)
	-- 将选中的除外组（包括本卡和前一步选择的恐龙族怪兽）从墓地除外，作为发动代价。
	Duel.Remove(rg1,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 登记本连锁的操作为特殊召唤：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 筛选卡组中满足最终条件：恐龙族、等级等于宣言等级且可以被特殊召唤的怪兽。
function c38572779.sfilter(c,e,tp,lv)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：从卡组选择1只与宣言等级相同的恐龙族怪兽特殊召唤；若成功，则给它登记结束阶段破坏的标记，并设置结束阶段破坏的处理效果。
function c38572779.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区没有空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡（将选择消息写入缓存）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只等级等于宣言等级且符合条件的恐龙族怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c38572779.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤到我方场上，若召唤成功则继续为它设置结束阶段破坏效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(38572779,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c38572779.descon)
		e1:SetOperation(c38572779.desop)
		-- 将结束阶段破坏效果注册到该怪兽，使其在结束阶段被破坏。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏效果的发动条件：确认该怪兽仍带有对应的特殊召唤场次标识（fid）；若该标识不存在（怪兽已离场或重置），则效果不再适用。
function c38572779.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(38572779)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 破坏效果的解决：破坏被这个效果特殊召唤的怪兽。
function c38572779.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将那只怪兽破坏（作为结束阶段破坏处理）。
	Duel.Destroy(tc,REASON_EFFECT)
end
