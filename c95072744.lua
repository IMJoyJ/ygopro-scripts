--影雄の烬 エグリスタ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以岩石族以外的自己墓地1只「影依」怪兽为对象才能发动。那只怪兽的反转的场合发动的效果适用。
-- ②：这张卡被效果送去墓地的场合才能发动（这个效果发动的回合，自己不是「影依」怪兽不能从额外卡组特殊召唤）。自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只「影依」融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（反转复制效果）、②效果（送墓融合召唤效果），并设置额外卡组特殊召唤限制的计数器
function s.initial_effect(c)
	-- ①：这张卡反转的场合，以岩石族以外的自己墓地1只「影依」怪兽为对象才能发动。那只怪兽的反转的场合发动的效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"复制效果"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动（这个效果发动的回合，自己不是「影依」怪兽不能从额外卡组特殊召唤）。自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只「影依」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_FUSION_SUMMON)
	e2:SetCondition(s.fspcon)
	e2:SetCost(s.fspcost)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	-- 注册自定义活动计数器，用于检测本回合玩家从额外卡组特殊召唤非「影依」怪兽的次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	s.shadoll_flip_effect=e1
end
-- 计数器过滤函数：过滤出从额外卡组特殊召唤的非「影依」怪兽（用于限制非「影依」怪兽的特殊召唤）
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x9d) and c:IsFaceup()
end
-- 过滤函数：选择墓地中的「影依」反转怪兽
function s.rfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsSetCard(0x9d)
end
-- 过滤函数：选择自己墓地中岩石族以外、卡名不同于本卡且具有反转效果的「影依」怪兽，并确认其反转效果的目标选择可以被合法执行
function s.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x9d) and not c:IsRace(RACE_ROCK) and not c:IsCode(id)) then return false end
	local te=c.shadoll_flip_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg and tg(e,tp,eg,ep,ev,re,r,rp,0)
end
-- ①效果的Target函数：选择墓地中岩石族以外的1只「影依」怪兽作为对象，并代入执行该怪兽反转效果的Target处理
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.efffilter(chkc,e,tp,eg,ep,ev,re,r,rp) end
	-- 检查自己墓地是否存在满足条件的「影依」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.efffilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	-- 提示玩家选择作为效果对象的目标卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己墓地1只满足条件的「影依」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.efffilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	-- 清除当前连锁的对象信息（因为复制效果时，原效果的对象不应直接作为此效果的对象，需要重新建立关系）
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te=tc.shadoll_flip_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，防止因复制效果而产生不正确的响应提示
	Duel.ClearOperationInfo(0)
end
-- ①效果的Operation函数：适用作为对象的「影依」怪兽的反转效果
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		local te=tc.shadoll_flip_effect
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
-- ②效果的Condition函数：检查是否在伤害步骤之外，且这张卡是被效果送去墓地
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL and e:GetHandler():IsReason(REASON_EFFECT)
end
-- ②效果的Cost函数：检查本回合是否未从额外卡组特殊召唤过非「影依」怪兽，并注册本回合不能从额外卡组特殊召唤非「影依」怪兽的誓约限制
function s.fspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否未进行过不符合限制条件的特殊召唤（即未从额外卡组特殊召唤过非「影依」怪兽）
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不是「影依」怪兽不能从额外卡组特殊召唤）。自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只「影依」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能从额外卡组特殊召唤非「影依」怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：禁止从额外卡组特殊召唤非「影依」怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9d) and c:IsLocation(LOCATION_EXTRA)
end
-- 融合素材过滤函数：过滤出可以被除外且不受当前效果影响的怪兽
function s.mfilter(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤函数：过滤出额外卡组中可以被融合召唤的「影依」融合怪兽，并检查融合素材是否充足
function s.sfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 墓地融合素材过滤函数：过滤出墓地中可以作为融合素材且可以被除外的怪兽
function s.gfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and s.mfilter(c,e)
end
-- ②效果的Target函数：检查手卡、场上、墓地是否存在可用的融合素材，以及额外卡组是否存在可融合召唤的「影依」融合怪兽，并设置特殊召唤与除外的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可以作为融合素材且能被除外的怪兽组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
			-- 合并自己墓地中可以作为融合素材且能被除外的怪兽组
			+Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_GRAVE,0,nil,e)
		-- 检查额外卡组是否存在可以使用上述素材进行融合召唤的「影依」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果提供的素材时，是否能进行融合召唤
				res=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前连锁的操作信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置当前连锁的操作信息为：将手卡、场上、墓地的卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD)
end
-- ②效果的Operation函数：选择1只「影依」融合怪兽，将手卡、场上、墓地的怪兽作为素材除外，从额外卡组融合召唤该怪兽
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡和场上可以作为融合素材且能被除外的怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
		-- 合并自己墓地中可以作为融合素材且能被除外的怪兽组
		+Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中可以使用上述素材进行融合召唤的「影依」融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，额外卡组中可以融合召唤的「影依」融合怪兽组
		sg2=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 判断是否使用常规的融合素材（手卡、场上、墓地）进行融合召唤，或者是否不使用连锁素材的效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家从手卡、场上、墓地的可用素材中选择融合召唤所需的素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat<2 then goto cancel end
			tc:SetMaterial(mat)
			-- 将选定的融合素材以表侧表示除外
			Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤处理与除外处理不视为同时进行
			Duel.BreakEffect()
			-- 将选定的融合怪兽以表侧表示融合召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 玩家从连锁素材效果提供的素材中选择融合召唤所需的素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat<2 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
end
