--融合呪印生物－光
-- 效果：
-- 这张卡可以作为1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。此外，把需要的融合素材怪兽（包含这张卡）解放才能发动。把以那些解放的怪兽为融合素材的1只光属性的融合怪兽从额外卡组特殊召唤。
function c15717011.initial_effect(c)
	-- 此外，把需要的融合素材怪兽（包含这张卡）解放才能发动。把以那些解放的怪兽为融合素材的1只光属性的融合怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(15717011,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetCost(c15717011.cost)
	e1:SetTarget(c15717011.target)
	e1:SetOperation(c15717011.operation)
	c:RegisterEffect(e1)
	-- 这张卡可以作为1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(c15717011.subcon)
	c:RegisterEffect(e2)
end
-- 代替融合素材效果仅在自身位于手牌、怪兽区或墓地时适用。
function c15717011.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 筛选符合条件的融合怪兽：必须是光属性融合怪兽、能够被特殊召唤，并且当前可获得的解放素材（含本卡）能够构成其融合素材。
function c15717011.filter(c,e,tp,m,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 筛选可作为解放并可作为融合素材的怪兽：必须是怪兽区里的卡，能够作为融合素材，且是自己场上的卡或对方场上的表侧表示卡。
function c15717011.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial() and (c:IsControler(tp) or c:IsFaceup())
end
-- 作为额外的素材合法性检查，验证所选融合素材组中的所有卡都能够被解放。
function c15717011.fcheck(tp,sg,fc)
	-- 具体检查场上是否存在至少与所选素材数量相同的可解放卡，且这些卡都属于所选素材组。
	return Duel.CheckReleaseGroup(tp,aux.IsInGroup,#sg,nil,sg)
end
-- 此效果没有预先支付代价，仅设置标记以允许在目标阶段进行解放素材的操作，并返回 true 允许发动。
function c15717011.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 发动时先检查可能性，再让玩家选择要特殊召唤的光属性融合怪兽，选择一组包含这张卡在内的融合素材，将其解放作为代价，并记录对应怪兽卡号，设置特殊召唤的操作信息。
function c15717011.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=tp+0x100
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 获取可解放的怪兽组，并筛选出可以作为融合素材的怪兽作为候选。
		local mg=Duel.GetReleaseGroup(tp):Filter(c15717011.mfilter,nil,tp)
		-- 设置额外的融合素材合法性检查函数，使后续的融合素材选择在合法范围内。
		aux.FCheckAdditional=c15717011.fcheck
		if c59160188 then c59160188.re_activated=true end
		-- 检查额外卡组中是否存在至少一张符合条件的融合怪兽，同时利用 CheckFusionMaterial 与 FCheckAdditional 确保能够从候选素材中选出满足且可解放的素材。
		local res=Duel.IsExistingMatchingCard(c15717011.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,c,chkf)
		-- 清除额外检查函数，避免干扰后续其他效果的判定。
		aux.FCheckAdditional=nil
		if c59160188 then c59160188.re_activated=false end
		return res
	end
	-- 正式选择阶段重新获取可解放的融合素材候选组，以反映当前最新状态。
	local mg=Duel.GetReleaseGroup(tp):Filter(c15717011.mfilter,nil,tp)
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 再次设置额外的素材可解放性检查，确保玩家选择的融合素材满足解放条件。
	aux.FCheckAdditional=c15717011.fcheck
	if c59160188 then c59160188.re_activated=true end
	-- 从额外卡组中选择1张符合条件的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c15717011.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg,c,chkf)
	-- 根据选中的融合怪兽，从候选素材中选择一组融合素材（必须包含这张卡）。
	local mat=Duel.SelectFusionMaterial(tp,g:GetFirst(),mg,c,chkf)
	-- 清除额外检查函数。
	aux.FCheckAdditional=nil
	if c59160188 then c59160188.re_activated=false end
	-- 处理代替解放效果（如暗影敌托邦）的次数限制，确保本次解放合法。
	aux.UseExtraReleaseCount(mat,tp)
	-- 将选中的融合素材作为发动代价解放。
	Duel.Release(mat,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置操作信息：本次效果将特殊召唤1只怪兽，特殊召唤来源为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 筛选函数：用于效果处理时检索要特殊召唤的融合怪兽，要求其卡号等于之前记录的卡号、可以被特殊召唤，并且有足够的额外卡组怪兽区空格。
function c15717011.filter2(c,e,tp,code)
	-- 具体的筛选条件：卡号一致、可特殊召唤、且额外卡组怪兽区有空格。
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果处理函数：根据记录的卡号，从额外卡组找到对应的融合怪兽并特殊召唤。
function c15717011.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 从额外卡组检索第一张满足条件的融合怪兽。
	local tc=Duel.GetFirstMatchingCard(c15717011.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,code)
	if tc then
		-- 将检索到的融合怪兽以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
