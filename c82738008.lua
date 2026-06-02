--赫の烙印
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「死狱乡」怪兽或「阿不思的落胤」为对象才能发动。那只怪兽加入手卡。那之后，以下效果可以适用。
-- ●自己的手卡·场上的怪兽作为融合素材除外，把1只8星以上的融合怪兽融合召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
function c82738008.initial_effect(c)
	-- 记录此卡记载了「阿不思的落胤」的卡片密码
	aux.AddCodeList(c,68468459)
	-- ①：以自己墓地1只「死狱乡」怪兽或「阿不思的落胤」为对象才能发动。那只怪兽加入手卡。那之后，以下效果可以适用。●自己的手卡·场上的怪兽作为融合素材除外，把1只8星以上的融合怪兽融合召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,82738008+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c82738008.target)
	e1:SetOperation(c82738008.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的怪兽属于「死狱乡」字段或是「阿不思的落胤」且能够加入手卡
function c82738008.filter(c)
	return (c:IsSetCard(0x164) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) and c:IsAbleToHand()
end
-- 效果发动的靶向/准备函数：选择自己墓地符合条件的1只怪兽作为对象，并设置加入手卡的操作信息
function c82738008.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82738008.filter(chkc) end
	-- 判断自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c82738008.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地的1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c82738008.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：包含将选定的目标怪兽加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤条件：能够被效果除外且不受该效果影响的卡
function c82738008.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中等级在8星以上的融合怪兽，且能融合召唤特殊召唤
function c82738008.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果的执行：将选择的对象怪兽加入手卡，之后玩家可以选择将自己手卡·场上的怪兽除外作为融合素材，从额外卡组融合召唤1只8星以上的融合怪兽
function c82738008.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为发动对象的那只墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽仍存在且成功加入手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		local chkf=tp
		-- 获取手卡·场上可用于融合召唤且能被除外的融合素材卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(c82738008.filter1,nil,e)
		-- 获取自己额外卡组中可以使用上述素材融合召唤的8星以上的融合怪兽
		local sg1=Duel.GetMatchingGroup(c82738008.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 检查玩家是否存在连锁素材等替代融合召唤的效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 利用替代素材效果获取可以特殊召唤的符合条件的融合怪兽
			sg2=Duel.GetMatchingGroup(c82738008.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		-- 如果存在可融合召唤的怪兽，则让玩家选择是否适用融合召唤效果
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(82738008,0)) then  --"是否进行融合召唤？"
			-- 中断当前效果处理，使后续动作不与加入手卡视为同时处理
			Duel.BreakEffect()
			-- 洗切手卡
			Duel.ShuffleHand(tp)
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 给玩家提示选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用手卡·场上的怪兽作为素材进行常规融合召唤
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 选择融合召唤所必须的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选择的融合素材以表侧表示除外
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将该融合怪兽表侧表示融合召唤特殊召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 使用替代素材效果选择融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			-- 这个效果特殊召唤的怪兽在这个回合不能直接攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
			tc:CompleteProcedure()
		end
	end
end
