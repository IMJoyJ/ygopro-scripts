--黄金郷の七摩天
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是不死族怪兽。
-- ②：卡的效果让不死族怪兽特殊召唤的场合，以魔法与陷阱区域盖放的1张卡为对象才能发动。盖放的那张卡在这个回合不能发动。
function c95034141.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是不死族怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95034141,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,95034141)
	e2:SetTarget(c95034141.sptg)
	e2:SetOperation(c95034141.spop)
	c:RegisterEffect(e2)
	-- ②：卡的效果让不死族怪兽特殊召唤的场合，以魔法与陷阱区域盖放的1张卡为对象才能发动。盖放的那张卡在这个回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95034141,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,95034142)
	e2:SetCondition(c95034141.alcon)
	e2:SetTarget(c95034141.altg)
	e2:SetOperation(c95034141.alop)
	c:RegisterEffect(e2)
end
-- 过滤可作为融合素材的不死族怪兽（必须能送去墓地）
function c95034141.filter0(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- 过滤可作为融合素材的不死族怪兽（考虑效果免疫）
function c95034141.filter1(c,e)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的融合怪兽
function c95034141.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与合法性检测
function c95034141.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上满足条件的融合素材怪兽组（必须是不死族）
		local mg1=Duel.GetFusionMaterial(tp):Filter(c95034141.filter0,nil)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c95034141.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如连锁素材）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c95034141.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特召1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置送去墓地的操作信息（将手卡或场上的素材送去墓地）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND)
end
-- 融合召唤效果的处理（选择怪兽、确定素材、送去墓地并特殊召唤）
function c95034141.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取效果处理时可用的融合素材怪兽组（过滤效果免疫）
	local mg1=Duel.GetFusionMaterial(tp):Filter(c95034141.filter1,nil,e)
	-- 获取当前素材下可以融合召唤的怪兽集合
	local sg1=Duel.GetMatchingGroup(c95034141.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取效果处理时玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的怪兽集合
		sg2=Duel.GetMatchingGroup(c95034141.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（若不能使用连锁素材或玩家选择不使用）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材怪兽送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤不与送去墓地视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示融合召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤因卡的效果而特殊召唤成功的不死族怪兽
function c95034141.alfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsFaceup() and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
end
-- 检查是否有不死族怪兽因卡的效果特殊召唤成功，作为效果发动条件
function c95034141.alcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95034141.alfilter,1,nil)
end
-- 过滤魔法与陷阱区域盖放的卡（不含场地区）
function c95034141.cfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 选择魔法与陷阱区域盖放的1张卡作为效果对象
function c95034141.altg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c95034141.cfilter(chkc) end
	-- 在发动时检测场上是否存在可作为对象的盖放魔陷卡
	if chk==0 then return Duel.IsExistingTarget(c95034141.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要禁止发动的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(95034141,2))  --"请选择要禁止发动的卡"
	-- 选择并锁定1张盖放的魔陷卡作为效果对象
	local g=Duel.SelectTarget(tp,c95034141.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
end
-- 使作为对象的盖放卡在这个回合不能发动
function c95034141.alop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的盖放卡对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 盖放的那张卡在这个回合不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
