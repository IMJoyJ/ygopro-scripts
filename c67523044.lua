--グラウンド・ゼノ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只恐龙族调整或者恐龙族通常怪兽加入手卡。那之后，选自己1张手卡破坏。
-- ②：把墓地的这张卡除外才能发动。从自己的手卡·场上把恐龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c67523044.initial_effect(c)
	-- ①：从卡组把1只恐龙族调整或者恐龙族通常怪兽加入手卡。那之后，选自己1张手卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67523044,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,67523044)
	e1:SetTarget(c67523044.target)
	e1:SetOperation(c67523044.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的手卡·场上把恐龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67523044,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,67523045)
	-- 把墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c67523044.fstg)
	e2:SetOperation(c67523044.fsop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中满足条件的恐龙族调整或恐龙族通常怪兽
function c67523044.filter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_TUNER+TYPE_NORMAL) and c:IsAbleToHand()
end
-- ①号效果的发动准备与检测，设置检索和破坏的操作信息
function c67523044.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在可检索的恐龙族调整或通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67523044.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置破坏手卡中1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
end
-- ①号效果的处理：检索恐龙族调整或通常怪兽，之后破坏1张手卡
function c67523044.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c67523044.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return false end
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽加入手卡
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方玩家展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果，使后续的破坏处理不与检索同时进行
		Duel.BreakEffect()
		-- 洗切手卡
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要破坏的手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择自己手卡中的1张卡
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
		-- 破坏选中的手卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
-- 过滤不受效果影响的怪兽（用于融合素材筛选）
function c67523044.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的恐龙族融合怪兽
function c67523044.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR)
		and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②号效果的发动准备与检测，确认是否存在可融合召唤的恐龙族融合怪兽
function c67523044.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检测额外卡组是否存在可以使用当前素材进行融合召唤的恐龙族融合怪兽
		local res=Duel.IsExistingMatchingCard(c67523044.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检测在连锁素材效果下是否存在可融合召唤的恐龙族融合怪兽
				res=Duel.IsExistingMatchingCard(c67523044.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②号效果的处理：选择1只恐龙族融合怪兽，将素材送去墓地并进行融合召唤
function c67523044.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡和场上不受此卡效果影响以外的融合素材怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c67523044.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的恐龙族融合怪兽组
	local sg1=Duel.GetMatchingGroup(c67523044.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的恐龙族融合怪兽组
		sg2=Duel.GetMatchingGroup(c67523044.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（而非连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合召唤该怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材因效果、素材、融合原因送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使送去墓地与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下让玩家选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
