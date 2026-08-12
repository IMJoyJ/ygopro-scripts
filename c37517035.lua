--アルトメギア・マスターワーク－継承－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。包含「神艺」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。场地区域有卡存在的场合，再让这个效果特殊召唤的怪兽的攻击力上升500。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地3张「神艺」卡为对象才能发动（同名卡最多1张）。那些卡回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（在双方主要阶段可发动的融合召唤效果，1回合1次）和②效果（墓地中除外的起动效果，取对象让墓地的「神艺」卡回到卡组，1回合1次）
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。包含「神艺」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。场地区域有卡存在的场合，再让这个效果特殊召唤的怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fscon)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地3张「神艺」卡为对象才能发动（同名卡最多1张）。那些卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果的发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：只有在主要阶段才能发动
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己或对方的主要阶段
	return Duel.IsMainPhase()
end
-- 融合怪兽的过滤条件：必须是融合怪兽、满足连锁素材的附加条件、可以被融合召唤特殊召唤，并且能用给定的融合素材组进行融合召唤
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材的附加检查：素材组中必须至少包含1张「神艺」怪兽
function s.check(tp,g,fc)
	return g:IsExists(Card.IsFusionSetCard,1,nil,0x1cd)
end
-- ①效果的取对象（目标）处理：检查额外卡组是否存在可以用手卡·场上的融合素材进行融合召唤的融合怪兽（包括适用连锁素材效果的情况），若存在则可以发动，并设置特殊召唤的操作信息
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得自己可用的融合素材（手卡·场上的怪兽），并过滤掉不受这张卡效果影响的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 设置融合素材的附加检查函数：素材中必须包含「神艺」怪兽
		aux.FCheckAdditional=s.check
		-- 检查额外卡组是否存在至少1只满足条件、能用该融合素材组特殊召唤的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得自己受到的连锁素材的效果（如融合之门等代替素材的效果）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 改用连锁素材效果提供的素材组和过滤条件，再次检查额外卡组是否存在可以融合召唤的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除融合素材的附加检查函数，恢复默认判定
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽（用于王家长眠之谷等卡的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理：收集额外卡组中可以融合召唤的融合怪兽，让玩家选择1只并选择融合素材（包含「神艺」怪兽），把素材送去墓地后将该融合怪兽特殊召唤；场地区域有卡存在的场合，再让该怪兽的攻击力上升500
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得自己可用的融合素材（手卡·场上的怪兽），并过滤掉不受这张卡效果影响的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 设置融合素材的附加检查函数：素材中必须包含「神艺」怪兽
	aux.FCheckAdditional=s.check
	-- 取得额外卡组中所有满足条件、能用该融合素材组特殊召唤的融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	-- 取得自己受到的连锁素材的效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材效果提供的素材组和过滤条件，取得额外卡组中可以融合召唤的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 判断所选融合怪兽是否使用通常的融合素材组进行召唤（若该怪兽同时可用连锁素材召唤，则询问玩家是否适用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从可用的融合素材中选择一组（必须包含「神艺」怪兽的）融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			-- 把选定的融合素材作为融合素材送去墓地
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的特殊召唤与素材送去墓地视为不同时处理
			Duel.BreakEffect()
			-- 把选定的融合怪兽以融合召唤的方式特殊召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材效果提供的素材组中选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
		-- 检查双方的场地区域是否有卡存在
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
			-- 中断当前效果，使攻击力上升的处理与特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 场地区域有卡存在的场合，再让这个效果特殊召唤的怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	-- 清除融合素材的附加检查函数，恢复默认判定
	aux.FCheckAdditional=nil
end
-- ②效果对象的过滤条件：自己墓地的「神艺」卡，且能够回到卡组、可以作为效果的对象
function s.tdfilter(c)
	return c:IsSetCard(0x1cd) and c:IsAbleToDeck() and c:IsCanBeEffectTarget()
end
-- ②效果的取对象处理：从自己墓地选择3张卡名互不相同的「神艺」卡作为对象，并设置回到卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得自己墓地中除这张卡以外满足条件的「神艺」卡
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查墓地中是否存在3张卡名互不相同的满足条件的卡，存在才能发动
	if chk==0 then return g:CheckSubGroup(aux.dncheck,3,3) end
	-- 提示玩家：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择3张卡名互不相同的「神艺」卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 把选择的3张卡设置为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：这些卡将回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果的处理：取得与连锁关联的对象卡，过滤掉受王家长眠之谷影响的卡，把那些卡回到卡组并洗切
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁关联的对象卡，并过滤掉受王家长眠之谷影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 把那些对象卡回到卡组并洗切卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
