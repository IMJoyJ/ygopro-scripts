--ミキサーロイド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只机械族怪兽解放才能发动。从卡组把1只风属性以外的「机人」怪兽特殊召唤。
-- ②：把基本分支付一半，从自己墓地把包含这张卡的机械族怪兽任意数量除外才能发动。和除外的怪兽数量相同等级的1只「机人」融合怪兽从额外卡组无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c71340250.initial_effect(c)
	-- ①：把自己场上1只机械族怪兽解放才能发动。从卡组把1只风属性以外的「机人」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71340250,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,71340250)
	e1:SetCost(c71340250.cost)
	e1:SetTarget(c71340250.target)
	e1:SetOperation(c71340250.operation)
	c:RegisterEffect(e1)
	-- ②：把基本分支付一半，从自己墓地把包含这张卡的机械族怪兽任意数量除外才能发动。和除外的怪兽数量相同等级的1只「机人」融合怪兽从额外卡组无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71340250,1))  --"融合怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,71340251)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c71340250.spcost)
	e2:SetTarget(c71340250.sptg)
	e2:SetOperation(c71340250.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上的机械族怪兽，且解放后能腾出怪兽区域空位（若在主要怪兽区则无此限制）
function c71340250.costfilter(c,tp,ft)
	return c:IsRace(RACE_MACHINE) and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果的发动代价：解放自己场上1只机械族怪兽
function c71340250.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动阶段（chk==0）检查是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c71340250.costfilter,1,nil,tp,ft) end
	-- 让玩家选择1只满足过滤条件的可解放怪兽
	local sg=Duel.SelectReleaseGroup(tp,c71340250.costfilter,1,1,nil,tp,ft)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(sg,REASON_COST)
end
-- 过滤条件：卡组中风属性以外的「机人」怪兽，且可以被特殊召唤
function c71340250.filter(c,e,tp)
	return c:IsSetCard(0x16) and c:IsNonAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c71340250.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71340250.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理：从卡组将1只风属性以外的「机人」怪兽特殊召唤
function c71340250.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c71340250.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价检测：标记此效果需要进行后续的代价处理
function c71340250.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件：墓地中的机械族怪兽，且可以作为代价除外
function c71340250.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost()
end
-- 过滤条件：额外卡组中等级在指定数值以下、可以无视召唤条件特殊召唤的「机人」融合怪兽，且额外卡组怪兽出场区域有空位
function c71340250.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x16) and c:IsType(TYPE_FUSION) and c:IsLevelBelow(lv)
		-- 检查该怪兽是否可以无视召唤条件特殊召唤，且额外卡组怪兽出场区域有空位
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动准备：支付一半基本分，选择要除外的怪兽数量（等级），并将包含这张卡在内的对应数量的机械族怪兽除外
function c71340250.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 获取自己墓地中所有满足过滤条件的机械族怪兽
		local cg=Duel.GetMatchingGroup(c71340250.cfilter,tp,LOCATION_GRAVE,0,nil)
		return c:IsAbleToRemoveAsCost()
			-- 检查额外卡组中是否存在等级在墓地可除外怪兽总数以下的「机人」融合怪兽
			and Duel.IsExistingMatchingCard(c71340250.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,cg:GetCount())
	end
	-- 支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 重新获取自己墓地中所有满足过滤条件的机械族怪兽
	local cg=Duel.GetMatchingGroup(c71340250.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取额外卡组中所有满足特殊召唤条件的「机人」融合怪兽
	local tg=Duel.GetMatchingGroup(c71340250.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,cg:GetCount())
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
	-- 提示玩家选择要特殊召唤的融合怪兽的等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(71340250,2))  --"请选择要特殊召唤的融合怪兽的等级"
	-- 让玩家宣言一个可选的等级数值
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	local rg1=Group.CreateGroup()
	if lv>1 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg2=cg:Select(tp,lv-1,lv-1,c)
		rg1:Merge(rg2)
	end
	rg1:AddCard(c)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(rg1,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：额外卡组中等级等于指定数值、可以无视召唤条件特殊召唤的「机人」融合怪兽，且额外卡组怪兽出场区域有空位
function c71340250.sfilter(c,e,tp,lv)
	return c:IsSetCard(0x16) and c:IsType(TYPE_FUSION) and c:IsLevel(lv)
		-- 检查该怪兽是否可以无视召唤条件特殊召唤，且额外卡组怪兽出场区域有空位
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的效果处理：从额外卡组无视召唤条件特殊召唤1只与除外数量相同等级的「机人」融合怪兽，并注册结束阶段破坏的效果
function c71340250.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足过滤条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c71340250.sfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	-- 若成功无视召唤条件特殊召唤该怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(71340250,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c71340250.descon)
		e1:SetOperation(c71340250.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局延迟效果，用于在结束阶段破坏该怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段破坏效果的触发条件：该怪兽仍在场上且标记未失效
function c71340250.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(71340250)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段破坏效果的效果处理：破坏该怪兽
function c71340250.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果破坏该怪兽
	Duel.Destroy(tc,REASON_EFFECT)
end
