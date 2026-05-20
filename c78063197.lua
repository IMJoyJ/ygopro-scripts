--サクリファイス・フュージョン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只「眼纳祭神」融合怪兽融合召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以对方场上1只效果怪兽为对象才能发动。选自己场上1只「眼纳祭神」融合怪兽或「纳祭之魔」把作为对象的对方的效果怪兽当作那个效果的装备魔法卡使用来装备。
function c78063197.initial_effect(c)
	-- ①：自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只「眼纳祭神」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,78063197)
	e1:SetTarget(c78063197.target)
	e1:SetOperation(c78063197.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以对方场上1只效果怪兽为对象才能发动。选自己场上1只「眼纳祭神」融合怪兽或「纳祭之魔」把作为对象的对方的效果怪兽当作那个效果的装备魔法卡使用来装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78063197,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,78063198)
	-- 设置发动成本为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c78063197.eqtg)
	e2:SetOperation(c78063197.eqop)
	c:RegisterEffect(e2)
end
-- 过滤条件：可以被除外的卡
function c78063197.filter0(c)
	return c:IsAbleToRemove()
end
-- 过滤条件：可以被除外且不受当前效果影响的卡
function c78063197.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以进行融合召唤的「眼纳祭神」融合怪兽
function c78063197.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsSetCard(0x1110)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤条件：可以作为融合素材且可以被除外的怪兽
function c78063197.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- ①号效果的发动准备（收集融合素材并确认是否存在可融合召唤的怪兽，设置操作信息）
function c78063197.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡·场上可用于融合召唤且能被除外的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(c78063197.filter0,nil)
		-- 获取自己手卡·场上·墓地可作为融合素材且能被除外的怪兽卡片组
		local mg2=Duel.GetMatchingGroup(c78063197.filter3,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用当前素材融合召唤的「眼纳祭神」融合怪兽
		local res=Duel.IsExistingMatchingCard(c78063197.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可融合召唤的「眼纳祭神」融合怪兽
				res=Duel.IsExistingMatchingCard(c78063197.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从手卡·场上·墓地将卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 设置操作信息：从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①号效果的处理（选择融合怪兽，选出并除外融合素材，将其融合召唤）
function c78063197.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡·场上可用于融合召唤、能被除外且不受当前效果影响的卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c78063197.filter1,nil,e)
	-- 获取自己手卡·场上·墓地可作为融合素材且能被除外的怪兽卡片组
	local mg2=Duel.GetMatchingGroup(c78063197.filter3,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取额外卡组中可以使用当前素材融合召唤的「眼纳祭神」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c78063197.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，可以融合召唤的「眼纳祭神」融合怪兽组
		sg2=Duel.GetMatchingGroup(c78063197.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材等其他效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选好的融合素材以效果·素材·融合的原因表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与除外不视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：对方场上表侧表示的效果怪兽，且可以转移控制权
function c78063197.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
-- 过滤条件：自己场上未被无效、且拥有装备怪兽效果的表侧表示「眼纳祭神」融合怪兽或「纳祭之魔」
function c78063197.eqfilter(c)
	local m=_G["c"..c:GetCode()]
	return m and c:IsFaceup() and ((c:IsSetCard(0x1110) and c:IsType(TYPE_FUSION)) or c:IsCode(64631466))
		and not c:IsDisabled() and m.can_equip_monster and m.can_equip_monster(c)
end
-- ②号效果的发动准备（选择对方场上1只效果怪兽作为对象，并确认自己场上存在合法的装备怪兽）
function c78063197.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c78063197.filter(chkc) end
	-- 检查对方场上是否存在可以作为装备对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c78063197.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 并且自己场上存在可以装备该怪兽的「眼纳祭神」融合怪兽或「纳祭之魔」
		and Duel.IsExistingMatchingCard(c78063197.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只效果怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c78063197.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：装备卡片
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- ②号效果的处理（选择自己场上1只合法的怪兽，将作为对象的对方怪兽当作装备卡装备给它）
function c78063197.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的对方效果怪兽
	local tc1=Duel.GetFirstTarget()
	-- 提示玩家选择自己场上表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只「眼纳祭神」融合怪兽或「纳祭之魔」
	local g=Duel.SelectMatchingCard(tp,c78063197.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		local tc2=g:GetFirst()
		local m=_G["c"..tc2:GetCode()]
		if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc1:IsControler(1-tp) and tc2 then
			m.equip_monster(tc2,tp,tc1)
		end
	end
end
