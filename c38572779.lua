--幻創のミセラサウルス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把这张卡从手卡送去墓地才能发动。这次主要阶段中，自己场上的恐龙族怪兽不受对方发动的效果影响。
-- ②：从自己墓地把包含这张卡的恐龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只恐龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c38572779.initial_effect(c)
	-- 效果原文内容：①：自己·对方的主要阶段，把这张卡从手卡送去墓地才能发动。这次主要阶段中，自己场上的恐龙族怪兽不受对方发动的效果影响。
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
	-- 效果原文内容：②：从自己墓地把包含这张卡的恐龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只恐龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
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
-- 规则层面作用：判断是否处于主要阶段1或主要阶段2
function c38572779.immcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：当前阶段为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 规则层面作用：支付将此卡送去墓地的费用
function c38572779.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面作用：将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面作用：判断是否已使用过②效果
function c38572779.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家是否已使用过②效果
	if chk==0 then return Duel.GetFlagEffect(tp,38572779)==0 end
end
-- 规则层面作用：设置并注册免疫效果
function c38572779.immop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：这次主要阶段中，自己场上的恐龙族怪兽不受对方发动的效果影响。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 规则层面作用：设置效果目标为恐龙族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DINOSAUR))
	e1:SetValue(c38572779.efilter)
	-- 规则层面作用：判断当前是否为主阶段1
	if Duel.GetCurrentPhase()==PHASE_MAIN1 then
		e1:SetReset(RESET_PHASE+PHASE_MAIN1)
		-- 规则层面作用：为玩家注册一个在主要阶段1结束时重置的标识效果
		Duel.RegisterFlagEffect(tp,38572779,RESET_PHASE+PHASE_MAIN1,0,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_MAIN2)
		-- 规则层面作用：为玩家注册一个在主要阶段2结束时重置的标识效果
		Duel.RegisterFlagEffect(tp,38572779,RESET_PHASE+PHASE_MAIN2,0,1)
	end
	-- 规则层面作用：将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果原文内容：自己场上的恐龙族怪兽不受对方发动的效果影响。
function c38572779.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 规则层面作用：设置标记用于判断是否已发动②效果
function c38572779.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 规则层面作用：过滤满足条件的墓地恐龙族怪兽
function c38572779.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 规则层面作用：过滤满足条件的卡组恐龙族怪兽
function c38572779.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置②效果的发动条件
function c38572779.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 规则层面作用：获取满足条件的墓地恐龙族怪兽组
		local cg=Duel.GetMatchingGroup(c38572779.cfilter,tp,LOCATION_GRAVE,0,nil)
		return c:IsAbleToRemoveAsCost()
			-- 规则层面作用：检查场上是否有足够的召唤区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 规则层面作用：检查卡组中是否存在满足条件的恐龙族怪兽
			and Duel.IsExistingMatchingCard(c38572779.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,cg:GetCount())
	end
	-- 规则层面作用：获取满足条件的墓地恐龙族怪兽组
	local cg=Duel.GetMatchingGroup(c38572779.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 规则层面作用：获取满足条件的卡组恐龙族怪兽组
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
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38572779,2))  --"请选择要特殊召唤的怪兽的等级"
	-- 规则层面作用：让玩家宣言一个等级
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	local rg1=Group.CreateGroup()
	if lv>1 then
		-- 规则层面作用：提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg2=cg:Select(tp,lv-1,lv-1,c)
		rg1:Merge(rg2)
	end
	rg1:AddCard(c)
	-- 规则层面作用：将选中的卡除外
	Duel.Remove(rg1,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 规则层面作用：设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：过滤满足条件的卡组恐龙族怪兽
function c38572779.sfilter(c,e,tp,lv)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：处理②效果的发动
function c38572779.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 规则层面作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的卡组恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c38572779.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	-- 规则层面作用：特殊召唤选定的怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(38572779,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 效果原文内容：这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c38572779.descon)
		e1:SetOperation(c38572779.desop)
		-- 规则层面作用：将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 规则层面作用：判断是否为该效果对应的怪兽
function c38572779.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(38572779)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 效果原文内容：这个效果特殊召唤的怪兽在结束阶段破坏。
function c38572779.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 规则层面作用：在结束阶段破坏特殊召唤的怪兽
	Duel.Destroy(tc,REASON_EFFECT)
end
