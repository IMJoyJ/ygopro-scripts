--融合呪印生物－地
-- 效果：
-- ①：这张卡可以作为融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
-- ②：把地属性融合怪兽卡决定的一组融合素材怪兽（这张卡作为那之内的1只）从自己场上解放才能发动。把以那些解放的怪兽为融合素材的1只地属性融合怪兽从额外卡组特殊召唤。
function c88696724.initial_effect(c)
	-- ②：把地属性融合怪兽卡决定的一组融合素材怪兽（这张卡作为那之内的1只）从自己场上解放才能发动。把以那些解放的怪兽为融合素材的1只地属性融合怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(88696724,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetCost(c88696724.cost)
	e1:SetTarget(c88696724.target)
	e1:SetOperation(c88696724.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡可以作为融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(c88696724.subcon)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否在手卡、怪兽区域或墓地存在（代替融合素材效果的适用条件）
function c88696724.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 过滤额外卡组中可以被特殊召唤、且能以当前可用卡片（包含自身）作为融合素材的地属性融合怪兽
function c88696724.filter(c,e,tp,m,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 过滤场上可以作为融合素材的怪兽（自己场上的怪兽，或者对方场上表侧表示的怪兽）
function c88696724.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial() and (c:IsControler(tp) or c:IsFaceup())
end
-- 融合素材检查的辅助函数，用于验证选定的融合素材是否全部可以被解放
function c88696724.fcheck(tp,sg,fc)
	-- 检查选定的融合素材组中的所有卡片是否都满足可解放的条件
	return Duel.CheckReleaseGroup(tp,aux.IsInGroup,#sg,nil,sg)
end
-- 效果发动的代价处理函数，将Label设为1以标记进入了发动阶段的检测
function c88696724.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果发动的目标选择与合法性检查函数，处理解放素材作为代价并确定要特殊召唤的怪兽
function c88696724.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=tp+0x100
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 获取自己场上所有可解放且可作为融合素材的怪兽组
		local mg=Duel.GetReleaseGroup(tp):Filter(c88696724.mfilter,nil,tp)
		-- 临时设置融合素材检查的附加过滤函数，确保选中的素材必须是可解放的
		aux.FCheckAdditional=c88696724.fcheck
		if c59160188 then c59160188.re_activated=true end
		-- 检查额外卡组是否存在可以使用这张卡及场上其他怪兽作为素材进行融合召唤的地属性融合怪兽
		local res=Duel.IsExistingMatchingCard(c88696724.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,c,chkf)
		-- 重置融合素材检查的附加过滤函数
		aux.FCheckAdditional=nil
		if c59160188 then c59160188.re_activated=false end
		return res
	end
	-- 再次获取自己场上所有可解放且可作为融合素材的怪兽组
	local mg=Duel.GetReleaseGroup(tp):Filter(c88696724.mfilter,nil,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 临时设置融合素材检查的附加过滤函数，确保选中的素材必须是可解放的
	aux.FCheckAdditional=c88696724.fcheck
	if c59160188 then c59160188.re_activated=true end
	-- 让玩家从额外卡组选择1只满足条件的地属性融合怪兽
	local g=Duel.SelectMatchingCard(tp,c88696724.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg,c,chkf)
	-- 让玩家从可用素材中选择一组用于召唤该融合怪兽的融合素材（必须包含这张卡本身）
	local mat=Duel.SelectFusionMaterial(tp,g:GetFirst(),mg,c,chkf)
	-- 重置融合素材检查的附加过滤函数
	aux.FCheckAdditional=nil
	if c59160188 then c59160188.re_activated=false end
	-- 强制使用类似“暗影敌托邦”等代替解放效果的次数（如果有适用）
	aux.UseExtraReleaseCount(mat,tp)
	-- 将选定的融合素材怪兽全部解放作为发动的代价
	Duel.Release(mat,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置连锁信息，表明此效果的处理包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤额外卡组中卡名与选定代号相同、且可以特殊召唤到场上的怪兽
function c88696724.filter2(c,e,tp,code)
	-- 检查卡片是否与指定卡名相同、是否可以特殊召唤，以及额外卡组怪兽出场所需的怪兽区域空格是否足够
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果处理的执行函数，从额外卡组特殊召唤对应的地属性融合怪兽
function c88696724.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 从额外卡组中获取第1张满足特殊召唤条件且卡名与解放时确定的融合怪兽相同的卡
	local tc=Duel.GetFirstMatchingCard(c88696724.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,code)
	if tc then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
