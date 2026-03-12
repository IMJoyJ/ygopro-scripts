--融合呪印生物－闇
-- 效果：
-- ①：这张卡可以作为融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
-- ②：把暗属性融合怪兽卡决定的一组融合素材怪兽（这张卡作为那之内的1只）从自己场上解放才能发动。把以那些解放的怪兽为融合素材的1只暗属性融合怪兽从额外卡组特殊召唤。
function c52101615.initial_effect(c)
	-- ②：把暗属性融合怪兽卡决定的一组融合素材怪兽（这张卡作为那之内的1只）从自己场上解放才能发动。把以那些解放的怪兽为融合素材的1只暗属性融合怪兽从额外卡组特殊召唤。
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
	-- ①：这张卡可以作为融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(c52101615.subcon)
	c:RegisterEffect(e2)
end
-- 效果作用：判断此卡是否在手牌、怪兽区或墓地位置，满足条件时可作为融合素材代替。
function c52101615.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 效果作用：筛选满足类型为融合、属性为暗、可以特殊召唤且能通过融合素材检查的额外卡组中的融合怪兽。
function c52101615.filter(c,e,tp,m,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 效果作用：筛选场上满足位置为主怪区、可作为融合素材、控制者为玩家或正面表示的卡片。
function c52101615.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial() and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果作用：检查指定玩家是否能解放一组包含sg中所有卡片的融合素材。
function c52101615.fcheck(tp,sg,fc)
	-- 效果作用：检查指定玩家是否能解放一组包含sg中所有卡片的融合素材。
	return Duel.CheckReleaseGroup(tp,aux.IsInGroup,#sg,nil,sg)
end
-- 效果作用：设置效果标签为1，表示已支付费用。
function c52101615.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果作用：处理效果发动时的条件判断和选择特殊召唤目标及融合素材。
function c52101615.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=tp+0x100
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 效果作用：获取玩家场上可作为融合素材的卡片组。
		local mg=Duel.GetReleaseGroup(tp):Filter(c52101615.mfilter,nil,tp)
		-- 效果作用：设置额外融合检查函数为fcheck，用于验证是否满足融合条件。
		aux.FCheckAdditional=c52101615.fcheck
		if c59160188 then c59160188.re_activated=true end
		-- 效果作用：检测在额外卡组中是否存在满足条件的暗属性融合怪兽。
		local res=Duel.IsExistingMatchingCard(c52101615.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,c,chkf)
		-- 效果作用：清除额外融合检查函数，防止影响其他效果。
		aux.FCheckAdditional=nil
		if c59160188 then c59160188.re_activated=false end
		return res
	end
	-- 效果作用：获取玩家场上可作为融合素材的卡片组。
	local mg=Duel.GetReleaseGroup(tp):Filter(c52101615.mfilter,nil,tp)
	-- 效果作用：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：设置额外融合检查函数为fcheck，用于验证是否满足融合条件。
	aux.FCheckAdditional=c52101615.fcheck
	if c59160188 then c59160188.re_activated=true end
	-- 效果作用：从额外卡组中选择一张满足条件的暗属性融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c52101615.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg,c,chkf)
	-- 效果作用：选择指定融合怪兽的融合素材。
	local mat=Duel.SelectFusionMaterial(tp,g:GetFirst(),mg,c,chkf)
	-- 效果作用：清除额外融合检查函数，防止影响其他效果。
	aux.FCheckAdditional=nil
	if c59160188 then c59160188.re_activated=false end
	-- 效果作用：强制使用代替解放次数。
	aux.UseExtraReleaseCount(mat,tp)
	-- 效果作用：将选定的融合素材从场上解放作为发动代价。
	Duel.Release(mat,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
	-- 效果作用：设置连锁操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：筛选满足卡号、可特殊召唤且额外卡组有足够空间的卡片。
function c52101615.filter2(c,e,tp,code)
	-- 效果作用：筛选满足卡号、可特殊召唤且额外卡组有足够空间的卡片。
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果作用：执行特殊召唤操作，将符合条件的融合怪兽从额外卡组特殊召唤到场上。
function c52101615.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 效果作用：获取满足条件的额外卡组中的融合怪兽。
	local tc=Duel.GetFirstMatchingCard(c52101615.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,code)
	if tc then
		-- 效果作用：将符合条件的融合怪兽从额外卡组特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
