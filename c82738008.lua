--赫の烙印
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「死狱乡」怪兽或「阿不思的落胤」为对象才能发动。那只怪兽加入手卡。那之后，以下效果可以适用。
-- ●自己的手卡·场上的怪兽作为融合素材除外，把1只8星以上的融合怪兽融合召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
function c82738008.initial_effect(c)
	-- 记录这张卡在效果中记载了「阿不思的落胤」的卡名
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「死狱乡」怪兽或「阿不思的落胤」为对象才能发动。那只怪兽加入手卡。那之后，以下效果可以适用。●自己的手卡·场上的怪兽作为融合素材除外，把1只8星以上的融合怪兽融合召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
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
-- 过滤自己墓地中可以加入手牌的「死狱乡」怪兽或「阿不思的落胤」
function c82738008.filter(c)
	return (c:IsSetCard(0x164) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择
function c82738008.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82738008.filter(chkc) end
	-- 检查自己墓地是否存在可以加入手牌的「死狱乡」怪兽或「阿不思的落胤」
	if chk==0 then return Duel.IsExistingTarget(c82738008.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「死狱乡」怪兽或「阿不思的落胤」作为对象
	local g=Duel.SelectTarget(tp,c82738008.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将选择的对象卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤可以被除外且不受效果影响的融合素材怪兽
function c82738008.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的8星以上的融合怪兽
function c82738008.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的处理：将对象怪兽加入手牌，并可选进行融合召唤
function c82738008.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		local chkf=tp
		-- 获取自己手牌、场上可用于除外的融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c82738008.filter1,nil,e)
		-- 获取额外卡组中可以使用上述素材融合召唤的8星以上融合怪兽
		local sg1=Duel.GetMatchingGroup(c82738008.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 检查是否存在适用的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取使用连锁素材效果可以融合召唤的8星以上融合怪兽
			sg2=Duel.GetMatchingGroup(c82738008.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		-- 若存在可融合召唤的怪兽，询问玩家是否适用融合召唤效果
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(82738008,0)) then  --"是否进行融合召唤？"
			-- 中断当前效果，使后续处理与加入手牌不视为同时进行
			Duel.BreakEffect()
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的融合怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用常规融合素材进行融合召唤
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 玩家选择用于融合召唤的常规素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选择的融合素材以表侧表示除外
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果，使除外素材与特殊召唤不视为同时进行
				Duel.BreakEffect()
				-- 将融合怪兽以表侧表示融合召唤到场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 玩家选择使用连锁素材效果时的融合素材
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
			tc:RegisterEffect(e1)
			tc:CompleteProcedure()
		end
	end
end
