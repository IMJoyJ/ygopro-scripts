--タイラント・ダイナ・フュージョン
-- 效果：
-- ①：「恐龙摔跤手」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽只在场上表侧表示存在才有1次不会被战斗·效果破坏。
function c15543940.initial_effect(c)
	-- 效果原文内容：①：「恐龙摔跤手」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽只在场上表侧表示存在才有1次不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15543940,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15543940.target)
	e1:SetOperation(c15543940.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上且未被效果免疫的卡片。
function c15543940.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选满足以下条件的融合怪兽：属于恐龙摔跤手卡组、类型为融合、可特殊召唤、且符合融合素材条件。
function c15543940.filter2(c,e,tp,m,f,chkf)
	return c:IsSetCard(0x11a) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断是否满足发动条件：检查是否有满足条件的融合怪兽可从额外卡组特殊召唤。
function c15543940.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组，并筛选出在场上的卡片。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查在额外卡组中是否存在满足条件的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c15543940.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁中的融合素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁融合素材效果，则检查其是否满足条件。
				res=Duel.IsExistingMatchingCard(c15543940.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：表示将要特殊召唤1张来自额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 主发动效果函数：处理融合召唤及后续效果。
function c15543940.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组，并筛选出未被免疫效果影响的卡片。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c15543940.filter1,nil,e)
	-- 获取满足融合条件的额外卡组融合怪兽组。
	local sg1=Duel.GetMatchingGroup(c15543940.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁融合素材效果，则获取其对应的融合怪兽组。
		sg2=Duel.GetMatchingGroup(c15543940.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材组进行召唤，否则使用连锁融合素材组。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从指定融合素材组中选择融合所需的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将所选融合素材送入墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续效果视为错时处理。
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从指定融合素材组中选择融合所需的素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 效果原文内容：这个效果特殊召唤的怪兽只在场上表侧表示存在才有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(15543940,1))  --"「暴君恐龙融合」特殊召唤"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_NO_TURN_RESET)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(c15543940.indct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断该怪兽是否受到战斗或效果破坏时，返回1表示不被破坏，0表示可被破坏。
function c15543940.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
