--融合呪印生物－闇
-- 效果：
-- ①：这张卡可以作为融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
-- ②：把暗属性融合怪兽卡决定的一组融合素材怪兽（这张卡作为那之内的1只）从自己场上解放才能发动。把以那些解放的怪兽为融合素材的1只暗属性融合怪兽从额外卡组特殊召唤。
function c52101615.initial_effect(c)
	-- 把暗属性融合怪兽卡决定的一组融合素材怪兽（这张卡作为那之内的1只）从自己场上解放才能发动。把以那些解放的怪兽为融合素材的1只暗属性融合怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(52101615,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetCost(c52101615.cost)
	e1:SetTarget(c52101615.target)
	e1:SetOperation(c52101615.operation)
	c:RegisterEffect(e1)
	-- 这张卡可以作为融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(c52101615.subcon)
	c:RegisterEffect(e2)
end
-- 判断此卡是否位于手牌、场上或墓地，在这些位置时其代替融合素材效果适用。
function c52101615.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 筛选额外卡组中的暗属性融合怪兽，要求能被效果特殊召唤且能用给定的素材组（包含此卡）作为融合素材进行融合召唤。
function c52101615.filter(c,e,tp,m,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 筛选可解放的融合素材怪兽：位于怪兽区、可作为融合素材，并且是自己控制的怪兽或表侧表示的怪兽。
function c52101615.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial() and (c:IsControler(tp) or c:IsFaceup())
end
-- 设置额外检查函数，用于在选择融合素材时验证这些素材确实能够被解放。
function c52101615.fcheck(tp,sg,fc)
	-- 检查场上是否存在至少#sg张包含在sg中的可解放的怪兽。
	return Duel.CheckReleaseGroup(tp,aux.IsInGroup,#sg,nil,sg)
end
-- 代价步骤：将标记label设为1作为发动条件已满足的标识，然后返回true；实际的解放动作在target阶段完成。
function c52101615.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果发动时的目标选择与代价处理：先确认存在符合条件的暗属性融合怪兽，再选择要融合召唤的怪兽和一组包含此卡的融合素材，并解放这些素材。
function c52101615.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=tp+0x100
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 获取自己场上可解放的怪兽组，并筛选出其中可作为融合素材的怪兽。
		local mg=Duel.GetReleaseGroup(tp):Filter(c52101615.mfilter,nil,tp)
		-- 安装额外的素材检查函数，用于后续选择融合素材时验证候选素材能够被解放。
		aux.FCheckAdditional=c52101615.fcheck
		if c59160188 then c59160188.re_activated=true end
		-- 检查额外卡组中是否存在至少1只满足条件的暗属性融合怪兽。
		local res=Duel.IsExistingMatchingCard(c52101615.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,c,chkf)
		-- 移除之前安装的额外素材检查函数。
		aux.FCheckAdditional=nil
		if c59160188 then c59160188.re_activated=false end
		return res
	end
	-- 获取自己场上可解放的怪兽组，并筛选出其中可作为融合素材的怪兽。
	local mg=Duel.GetReleaseGroup(tp):Filter(c52101615.mfilter,nil,tp)
	-- 提示玩家从额外卡组选择要特殊召唤的融合怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 安装额外的素材检查函数，用于后续选择融合素材时验证候选素材能够被解放。
	aux.FCheckAdditional=c52101615.fcheck
	if c59160188 then c59160188.re_activated=true end
	-- 从额外卡组选择1只符合条件的暗属性融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c52101615.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg,c,chkf)
	-- 从候选素材怪兽中选择一组融合素材，必须包含此卡并满足该融合怪兽的融合素材要求。
	local mat=Duel.SelectFusionMaterial(tp,g:GetFirst(),mg,c,chkf)
	-- 移除之前安装的额外素材检查函数。
	aux.FCheckAdditional=nil
	if c59160188 then c59160188.re_activated=false end
	-- 处理类似暗影敌托邦等代替解放次数的效果。
	aux.UseExtraReleaseCount(mat,tp)
	-- 将选择的融合素材解放，作为效果的发动代价。
	Duel.Release(mat,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置本次效果处理的信息：将从额外卡组特殊召唤1只暗属性融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果处理时筛选要特殊召唤的怪兽：要求卡号与之前选择的一致、可被特殊召唤，且额外怪兽区有可用空格。
function c52101615.filter2(c,e,tp,code)
	-- 判断怪兽卡号一致、能够被特殊召唤，并且额外怪兽区存在足够的空格。
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果处理的实际特殊召唤：根据记录的卡号找到对应的融合怪兽并特殊召唤到场上。
function c52101615.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 从额外卡组获取与记录卡号相符且满足特殊召唤条件的融合怪兽。
	local tc=Duel.GetFirstMatchingCard(c52101615.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,code)
	if tc then
		-- 将该融合怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
