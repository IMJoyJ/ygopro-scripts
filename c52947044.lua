--フュージョン・デステニー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的手卡·卡组的怪兽作为融合素材，把以「命运英雄」怪兽为融合素材的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。这张卡的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 创建并注册卡牌效果，设置为发动时点、自由连锁、限制每回合发动一次
function s.initial_effect(c)
	-- ①：自己的手卡·卡组的怪兽作为融合素材，把以「命运英雄」怪兽为融合素材的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。这张卡的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：返回可以作为融合素材且能送入墓地的怪兽
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤函数：返回不在效果免疫状态且在手牌位置的卡
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsLocation(LOCATION_HAND)
end
-- 过滤函数：返回融合怪兽且以命运英雄为融合素材、可特殊召唤并满足融合条件的卡
function s.filter2(c,e,tp,m,f,chkf)
	-- 返回融合怪兽且以命运英雄为融合素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListSetCard(c,0xc008) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合检查函数：判断融合素材中是否存在命运英雄种族的卡
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0xc008)
end
-- 效果发动时的处理，检测是否有满足条件的融合怪兽可以特殊召唤
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组，并筛选出手牌中的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND)
		-- 获取玩家卡组中可作为融合素材的怪兽
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 设置融合检查附加函数为fcheck
		aux.FCheckAdditional=s.fcheck
		-- 检测是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检测是否有满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 取消融合检查附加函数
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息，表示将特殊召唤一只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果时的处理，选择并融合召唤一只融合怪兽，并注册其在下个回合结束时被破坏的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取玩家当前可用的融合素材组，并筛选出手牌中未被免疫的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取玩家卡组中可作为融合素材的怪兽
	local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 设置融合检查附加函数为fcheck
	aux.FCheckAdditional=s.fcheck
	-- 获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材或连锁融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 注册下个回合结束时破坏融合怪兽的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 设置该效果的标签为当前回合数
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		-- 将效果注册到玩家场上
		Duel.RegisterEffect(e1,tp)
	end
	-- 取消融合检查附加函数
	aux.FCheckAdditional=nil
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 注册发动后直到回合结束时禁止特殊召唤非暗属性英雄怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家场上
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否满足破坏条件，即不是当前回合且该怪兽仍存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 返回是否满足破坏条件
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)~=0
end
-- 执行破坏操作，将融合怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示卡片被破坏的动画
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 限制特殊召唤非暗属性英雄怪兽
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x8))
end
