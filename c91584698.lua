--EMトランプ・ウィッチ
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，自己主要阶段才能发动。从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- 【怪兽效果】
-- ①：把这张卡解放才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
function c91584698.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c91584698.sptg)
	e2:SetOperation(c91584698.spop)
	c:RegisterEffect(e2)
	-- ①：把这张卡解放才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c91584698.thcost)
	e3:SetTarget(c91584698.thtg)
	e3:SetOperation(c91584698.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：在场上且不受当前效果影响的卡
function c91584698.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以进行融合召唤且有可用融合素材的融合怪兽
function c91584698.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 灵摆效果的发动准备（检查是否存在可融合召唤的怪兽并设置操作信息）
function c91584698.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用于融合召唤的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在可以使用场上素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c91584698.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果适用下，额外卡组是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c91584698.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前连锁的操作信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果的处理（选择融合怪兽，选择并送去素材，进行融合召唤）
function c91584698.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上不受当前效果影响且可用于融合召唤的卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c91584698.filter1,nil,e)
	-- 获取额外卡组中可以使用场上素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c91584698.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果适用下，额外卡组中可融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c91584698.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（若不能使用连锁素材效果，或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从场上的素材中选择所选融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材因效果送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在适用连锁素材效果时，让玩家选择所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 怪兽效果的发动代价（解放自身）
function c91584698.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名为「融合」且能加入手卡
function c91584698.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 怪兽效果的发动准备（检查卡组·墓地是否有「融合」并设置操作信息）
function c91584698.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c91584698.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 怪兽效果的处理（从卡组·墓地将「融合」加入手卡）
function c91584698.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件且不受王家长眠之谷影响的「融合」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91584698.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选定的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
