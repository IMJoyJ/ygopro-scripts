--烙印竜アルビオン
-- 效果：
-- 「阿不思的落胤」＋光属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。自己的手卡·场上·墓地的怪兽作为融合素材除外，把除「烙印龙 白界龙」外的1只8星以下的融合怪兽融合召唤。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1张「烙印」魔法·陷阱卡加入手卡或在自己场上盖放。
function c87746184.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：「阿不思的落胤」＋光属性怪兽
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),1,true,true)
	-- ①：这张卡融合召唤的场合才能发动。自己的手卡·场上·墓地的怪兽作为融合素材除外，把除「烙印龙 白界龙」外的1只8星以下的融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87746184,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,87746184)
	e1:SetCondition(c87746184.condition)
	e1:SetTarget(c87746184.target)
	e1:SetOperation(c87746184.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1张「烙印」魔法·陷阱卡加入手卡或在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c87746184.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1张「烙印」魔法·陷阱卡加入手卡或在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87746184,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,87746185)
	e3:SetCondition(c87746184.thcon)
	e3:SetTarget(c87746184.thtg)
	e3:SetOperation(c87746184.thop)
	c:RegisterEffect(e3)
end
-- 烙印融合等卡片进行融合召唤时的素材合法性检查函数
function c87746184.branded_fusion_check(tp,sg,fc)
	-- 检查融合素材是否包含「阿不思的落胤」和光属性怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsFusionAttribute,ATTRIBUTE_LIGHT)
end
-- 效果①的发动条件：这张卡融合召唤成功，且不在伤害步骤
function c87746184.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否融合召唤成功，且当前不处于伤害步骤
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetCurrentPhase()&(PHASE_DAMAGE+PHASE_DAMAGE_CAL)==0
end
-- 过滤手卡·场上可以被效果除外且不受效果影响的融合素材怪兽
function c87746184.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中除「烙印龙 白界龙」以外、8星以下、可以进行融合召唤的融合怪兽
function c87746184.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(8) and not c:IsCode(87746184) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤墓地中可以作为融合素材除外且不受效果影响的怪兽
function c87746184.filter3(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 效果①的发动准备：检查是否存在可融合召唤的怪兽，并设置特殊召唤与除外的操作信息
function c87746184.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取手卡·场上可用于融合召唤且能被除外的怪兽组
		local mg1=Duel.GetFusionMaterial(tp):Filter(c87746184.filter1,nil,e)
		-- 获取自己墓地中可作为融合素材除外的怪兽组
		local mg2=Duel.GetMatchingGroup(c87746184.filter3,tp,LOCATION_GRAVE,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在满足条件的、可使用当前素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c87746184.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c87746184.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将场上·手卡·墓地的卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理：选择并融合召唤1只8星以下的融合怪兽，将素材除外
function c87746184.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 伤害步骤中不进行效果处理
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE+PHASE_DAMAGE_CAL)~=0 then return end
	-- 获取手卡·场上可用于融合召唤且能被除外的怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c87746184.filter1,nil,e)
	-- 获取自己墓地中可作为融合素材除外的怪兽组
	local mg2=Duel.GetMatchingGroup(c87746184.filter3,tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 获取额外卡组中可使用当前素材融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c87746184.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c87746184.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不使用连锁素材的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选作融合素材的怪兽表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤不与除外同时处理
			Duel.BreakEffect()
			-- 将融合怪兽表侧表示特殊召唤（融合召唤）
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家从连锁素材提供的范围内选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果②的注册函数：在这张卡被送去墓地的回合注册一个标志，用于在结束阶段发动效果
function c87746184.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(87746184,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的发动条件：这张卡被送去墓地的回合的结束阶段
function c87746184.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(87746184)>0
end
-- 过滤卡组中可以加入手卡或在场上盖放的「烙印」魔法·陷阱卡
function c87746184.thfilter(c)
	if not (c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- 效果②的发动准备：检查卡组中是否存在可检索或盖放的「烙印」魔陷
function c87746184.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「烙印」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c87746184.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的处理：从卡组选1张「烙印」魔法·陷阱卡加入手卡或在自己场上盖放
function c87746184.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 玩家从卡组选择1张满足条件的「烙印」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c87746184.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否将卡加入手卡（若不能盖放，或玩家在“加入手卡”和“盖放”中选择加入手卡）
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡在自己场上盖放
			Duel.SSet(tp,tc)
		end
	end
end
