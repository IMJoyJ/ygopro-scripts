--魂写しの同化
-- 效果：
-- 「影依」怪兽才能装备。宣言1个属性才能把这张卡发动。这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽变成宣言的属性。
-- ②：自己主要阶段才能发动。「影依」融合怪兽卡决定的包含这张卡的装备怪兽的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c60226558.initial_effect(c)
	-- 宣言1个属性才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c60226558.target)
	e1:SetOperation(c60226558.operation)
	c:RegisterEffect(e1)
	-- 「影依」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c60226558.eqlimit)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。「影依」融合怪兽卡决定的包含这张卡的装备怪兽的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,60226558)
	e3:SetTarget(c60226558.sptg)
	e3:SetOperation(c60226558.spop)
	c:RegisterEffect(e3)
end
-- 装备限制判定：只有「影依」怪兽才能装备这张卡。
function c60226558.eqlimit(e,c)
	return c:IsSetCard(0x9d)
end
-- 选择对象的过滤条件：场上表侧表示且属于「影依」系列的怪兽。
function c60226558.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9d)
end
-- 发动时的处理：选择场上1只表侧表示「影依」怪兽作为装备对象，并宣言1个属性；若没有合法对象则不能发动。
function c60226558.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c60226558.filter(chkc) end
	-- 发动合法性检查：确认场上存在至少1只符合条件的「影依」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c60226558.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“选择装备对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示「影依」怪兽作为装备对象，并将其设为这张卡的效果对象。
	local g=Duel.SelectTarget(tp,c60226558.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 给玩家显示“宣言属性”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 玩家从除对象怪兽当前属性外的所有属性中宣言1个属性（结果存入效果标签）。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
	-- 设置操作信息：本次操作涉及装备分类，记录装备卡信息用于处理。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动处理：将这张卡装备给对象怪兽，并赋予其变成宣言属性的效果。
function c60226558.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		local att=e:GetLabel()
		-- ①：装备怪兽变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:SetHint(CHINT_ATTRIBUTE,att)
	end
end
-- 融合素材过滤：将对当前效果免疫的卡排除，不能作为融合素材。
function c60226558.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽候选过滤：额外卡组中的「影依」融合怪兽，且能用当前素材（必须包含装备怪兽）进行融合召唤并可被融合特殊召唤。
function c60226558.filter2(c,e,tp,m,ec,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,ec,chkf)
end
-- ②效果发动条件判定：确认场上存在装备怪兽且在自己场上，并存在可用的「影依」融合素材组合；满足则设置特殊召唤操作信息。
function c60226558.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=e:GetHandler():GetEquipTarget()
		if ec:IsControler(1-tp) then return false end
		local chkf=tp
		-- 获取自己可用的融合素材组（手卡·场上的怪兽及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在可用当前素材组（包含装备怪兽）融合召唤的「影依」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c60226558.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,ec,nil,chkf)
		if not res then
			-- 获取自己受到的连锁素材效果（如果有）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材效果，则使用其提供的特殊素材组再次检查能否融合召唤。
				res=Duel.IsExistingMatchingCard(c60226558.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,ec,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次操作含特殊召唤与融合召唤分类，并记录要特殊召唤额外卡组的融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：选择1只「影依」融合怪兽，从手卡·场上将包含装备怪兽的融合素材送去墓地并融合召唤；若使用连锁素材则按其效果处理。
function c60226558.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec:IsControler(1-tp) or ec:IsImmuneToEffect(e) then return end
	local chkf=tp
	-- 获取可用的融合素材组，排除对效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c60226558.filter1,nil,e)
	-- 获取用当前素材组能够融合召唤的全部「影依」融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c60226558.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,ec,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（用于替代素材组或特殊处理）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 基于连锁素材提供的素材组，获取相应的融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c60226558.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,ec,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给玩家显示“选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否使用普通素材组进行融合召唤：若在普通素材候选内且不使用连锁素材，则执行普通融合；否则执行连锁素材融合。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中选择融合召唤所需的素材（必须包含装备怪兽）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,ec,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材从手卡·场上送去墓地（原因：效果+融合素材）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使之后的融合召唤特殊召唤不视为同时处理，以正确响应时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤到自己的场上（表侧攻击表示）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材组中选择融合召唤所需的素材（必须包含装备怪兽），用于连锁素材融合处理。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,ec,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
