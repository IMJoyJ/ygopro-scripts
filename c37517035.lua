--アルトメギア・マスターワーク－継承－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。包含「神艺」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。场地区域有卡存在的场合，再让这个效果特殊召唤的怪兽的攻击力上升500。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地3张「神艺」卡为对象才能发动（同名卡最多1张）。那些卡回到卡组。
local s,id,o=GetID()
-- 注册主要阶段进行包含「神艺」怪兽的融合召唤、以及从墓地除外回收3张「神艺」卡的效果
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
	-- 将墓地的此卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 确认当前正处于自己或对方的主要阶段
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是否为主要阶段的时点
	return Duel.IsMainPhase()
end
-- 能够进行融合召唤的额外卡组融合怪兽过滤条件
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查作为融合素材的卡片中是否至少包含1张「神艺」怪兽
function s.check(tp,g,fc)
	return g:IsExists(Card.IsFusionSetCard,1,nil,0x1cd)
end
-- 融合召唤效果的发动准备与合法性检查
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡和场上可作为融合素材的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 在系统中临时设定融合素材必须包含「神艺」怪兽的判定辅助函数
		aux.FCheckAdditional=s.check
		-- 检查额外卡组中是否存在可用当前素材融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查当前是否存在可适用的替代融合召唤效果的连锁状态
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否能通过替代融合效果召唤额外卡组的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 临时设定结束，清除融合素材包含「神艺」的额外限制条件
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息为从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的执行以及场地卡存在时攻击力上升500效果的适用
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前可用于进行融合的素材怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 将融合素材必须包含「神艺」怪兽的额外校验注册给系统
	aux.FCheckAdditional=s.check
	-- 获取额外卡组中所有符合融合召唤条件的怪兽
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	-- 检查并记录当前是否存在可用的替代融合召唤效果的连锁
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取替代融合效果下可以融合召唤的额外怪兽组
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 向玩家发送提示，请选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 判定被选中的融合怪兽是否可以通过常规的手卡/场上素材进行融合
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 为常规融合召唤选择对应的融合素材怪兽
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			-- 将选中的融合素材送入墓地以进行融合召唤
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 在素材送去墓地之后切断效果连锁以执行特召
			Duel.BreakEffect()
			-- 将选中的融合怪兽以融合召唤的方式特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 为替代连锁融合选择素材并执行对应的融合操作
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
		-- 检查场上（无论自己或对方）的场地魔法区域是否存在任何卡片
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
			-- 存在场地卡时，切断连锁以适用后续加攻效果
			Duel.BreakEffect()
			-- 注册使融合召唤出的怪兽攻击力上升500的单体持续加攻效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	-- 效果处理完毕，清除素材包含「神艺」的额外校验函数
	aux.FCheckAdditional=nil
end
-- 墓地中属于「神艺」字段、且能够返回卡组的卡片的过滤条件
function s.tdfilter(c)
	return c:IsSetCard(0x1cd) and c:IsAbleToDeck() and c:IsCanBeEffectTarget()
end
-- 墓地「神艺」卡返回卡组效果的发动准备与对象选择
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中除了此卡以外的所有符合条件的「神艺」卡片
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查墓地中是否存在3张不同名且能够返回卡组的「神艺」卡片
	if chk==0 then return g:CheckSubGroup(aux.dncheck,3,3) end
	-- 向玩家发送提示，请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张同名最多1张的「神艺」卡片作为回收对象
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的卡片作为效果的对象注册
	Duel.SetTargetCard(sg)
	-- 设置操作信息为将选中的卡片返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 返回卡组效果的执行
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联且未受墓地无效影响的作为对象的卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送回卡组并重新洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
