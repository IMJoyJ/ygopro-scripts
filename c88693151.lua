--トリックスター・フュージョン
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「淘气仙星」融合怪兽融合召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤。
function c88693151.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「淘气仙星」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88693151,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c88693151.target)
	e1:SetOperation(c88693151.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(88693151,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c88693151.thtg)
	e2:SetOperation(c88693151.thop)
	c:RegisterEffect(e2)
end
-- 过滤不受效果影响的怪兽（用于融合素材判定）
function c88693151.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「淘气仙星」融合怪兽
function c88693151.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xfb) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与合法性检测
function c88693151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材卡片组（包含手卡·场上）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「淘气仙星」融合怪兽
		local res=Duel.IsExistingMatchingCard(c88693151.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c88693151.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理
function c88693151.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤出不受当前效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c88693151.filter1,nil,e)
	-- 获取额外卡组中可以使用正常素材融合召唤的「淘气仙星」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c88693151.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以融合召唤的「淘气仙星」融合怪兽组
		sg2=Duel.GetMatchingGroup(c88693151.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用正常的融合素材进行融合召唤（若不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择一组满足融合条件的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤不与送墓同时处理（防止错时点）
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤墓地中可以加入手卡的「淘气仙星」怪兽
function c88693151.thfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 墓地回收效果的发动准备与目标选择
function c88693151.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c88693151.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的「淘气仙星」怪兽
	if chk==0 then return Duel.IsExistingTarget(c88693151.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「淘气仙星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88693151.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 墓地回收效果的处理与后续召唤限制的适用
function c88693151.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍符合条件，并将其加入手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 这个回合，自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c88693151.sumlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制该怪兽及同名怪兽通常召唤的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册限制该怪兽及同名怪兽特殊召唤的效果
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_MSET)
		-- 注册限制该怪兽及同名怪兽里侧表示通常召唤（盖放）的效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 限制召唤的同名卡判定函数
function c88693151.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
