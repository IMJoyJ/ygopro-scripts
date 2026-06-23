--融合呪印生物－光
-- 效果：
-- 这张卡可以作为1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。此外，把需要的融合素材怪兽（包含这张卡）解放才能发动。把以那些解放的怪兽为融合素材的1只光属性的融合怪兽从额外卡组特殊召唤。
function c15717011.initial_effect(c)
	-- 这张卡可以作为1只融合素材怪兽的代替。
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
	-- 此外，把需要的融合素材怪兽（包含这张卡）解放才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(c15717011.subcon)
	c:RegisterEffect(e2)
end
-- 将目标怪兽特殊召唤
function c15717011.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 检索满足条件的卡片组
function c15717011.filter(c,e,tp,m,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 筛选可作为融合素材的怪兽
function c15717011.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial() and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查融合素材是否满足条件
function c15717011.fcheck(tp,sg,fc)
	-- 检查融合素材是否满足条件
	return Duel.CheckReleaseGroup(tp,aux.IsInGroup,#sg,nil,sg)
end
-- 设置效果发动标记
function c15717011.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 检查是否满足发动条件并选择融合怪兽
function c15717011.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=tp+0x100
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 获取可解放的怪兽组
		local mg=Duel.GetReleaseGroup(tp):Filter(c15717011.mfilter,nil,tp)
		-- 设置融合检查附加条件
		aux.FCheckAdditional=c15717011.fcheck
		if c59160188 then c59160188.re_activated=true end
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c15717011.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,c,chkf)
		-- 清除融合检查附加条件
		aux.FCheckAdditional=nil
		if c59160188 then c59160188.re_activated=false end
		return res
	end
	-- 获取可解放的怪兽组
	local mg=Duel.GetReleaseGroup(tp):Filter(c15717011.mfilter,nil,tp)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置融合检查附加条件
	aux.FCheckAdditional=c15717011.fcheck
	if c59160188 then c59160188.re_activated=true end
	-- 选择要特殊召唤的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c15717011.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg,c,chkf)
	-- 选择融合素材
	local mat=Duel.SelectFusionMaterial(tp,g:GetFirst(),mg,c,chkf)
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
	if c59160188 then c59160188.re_activated=false end
	-- 使用额外解放次数
	aux.UseExtraReleaseCount(mat,tp)
	-- 解放融合素材
	Duel.Release(mat,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 筛选可特殊召唤的融合怪兽
function c15717011.filter2(c,e,tp,code)
	-- 判断是否满足特殊召唤条件
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 执行特殊召唤操作
function c15717011.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 检索满足条件的融合怪兽
	local tc=Duel.GetFirstMatchingCard(c15717011.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,code)
	if tc then
		-- 将融合怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
