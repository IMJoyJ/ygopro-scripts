--アルトメギア・マスターワーク－継承－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。包含「神艺」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。场地区域有卡存在的场合，再让这个效果特殊召唤的怪兽的攻击力上升500。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地3张「神艺」卡为对象才能发动（同名卡最多1张）。那些卡回到卡组。
local s,id,o=GetID()
-- 注册两个效果：①融合召唤效果和②墓地除外返回卡组效果
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
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：必须在主要阶段
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在主要阶段
	return Duel.IsMainPhase()
end
-- 过滤满足融合召唤条件的融合怪兽
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查融合素材中是否包含「神艺」怪兽
function s.check(tp,g,fc)
	return g:IsExists(Card.IsFusionSetCard,1,nil,0x1cd)
end
-- 效果①的发动时点处理：检查是否有满足条件的融合怪兽
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取可用的融合素材组，排除免疫效果的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 设置融合检查附加条件为检查是否包含神艺怪兽
		aux.FCheckAdditional=s.check
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除融合检查附加条件
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置连锁操作信息：准备特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理流程：选择并融合召唤融合怪兽
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用的融合素材组，排除免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 设置融合检查附加条件为检查是否包含神艺怪兽
	aux.FCheckAdditional=s.check
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 判断选择的怪兽是否来自基础融合组或是否需要选择连锁融合
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 选择连锁融合怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
		-- 判断场地区域是否有卡存在
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 给特殊召唤的怪兽增加500攻击力
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
end
-- 过滤墓地中的「神艺」卡
function s.tdfilter(c)
	return c:IsSetCard(0x1cd) and c:IsAbleToDeck() and c:IsCanBeEffectTarget()
end
-- 效果②的发动时点处理：选择3张不同名的「神艺」卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取墓地中的所有「神艺」卡
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查是否存在3张不同名的「神艺」卡
	if chk==0 then return g:CheckSubGroup(aux.dncheck,3,3) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张不同名的「神艺」卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 设置目标卡为选择的卡
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息：准备将卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的处理流程：将目标卡返回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的卡组并过滤受王家长眠之谷影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 将卡返回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
