--四天の龍 スターヴ・ヴェノム・フュージョン・ドラゴン
-- 效果：
-- 场上的暗属性怪兽×2
-- 这个卡名在规则上也当作「捕食植物」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，效果无效化，变成暗属性。
-- ②：对方把效果发动时才能发动。包含这张卡的自己·对方场上的暗属性怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括融合召唤手续、特殊召唤成功时的效果①以及对方效果发动时的融合召唤效果②
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：场上的暗属性怪兽×2
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：这张卡特殊召唤的场合，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，效果无效化，变成暗属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时才能发动。包含这张卡的自己·对方场上的暗属性怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 融合素材的过滤条件：场上的暗属性怪兽
function s.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsOnField()
end
-- ①效果的过滤条件：场上表侧表示，且攻击力不为0、效果未被无效或属性不是暗属性的怪兽
function s.nefilter(c)
	-- 判断卡片是否为表侧表示，且满足效果可以被无效、攻击力不为0或属性不是暗属性其中之一
	return (aux.NegateMonsterFilter(c) or not c:IsAttack(0) or not c:IsAttribute(ATTRIBUTE_DARK)) and c:IsFaceup()
end
-- ①效果的发动准备与目标检查（Target函数）：判断场上是否存在满足过滤条件的表侧表示怪兽，并在发动时选择1只其他的表侧表示怪兽作为对象，设置相关操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.nefilter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在至少1只除自身以外满足过滤条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(s.nefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 给玩家提示：选择要使效果无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择1只除自身以外满足过滤条件的表侧表示怪兽作为效果的对象并将其设为连锁对象
	local g=Duel.SelectTarget(tp,s.nefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置操作信息为无效目标怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果的处理（Operation函数）：使作为对象的怪兽攻击力变成0，效果无效化，并变成暗属性
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使与作为对象的怪兽相关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 变成暗属性
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e4:SetValue(ATTRIBUTE_DARK)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
	end
end
-- ②效果的发动条件：对方把效果发动时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤符合条件的己方场上融合素材：必须在场上、是暗属性且不受当前效果影响
function s.filter1(c,e)
	return c:IsOnField() and c:IsFusionAttribute(ATTRIBUTE_DARK) and not c:IsImmuneToEffect(e)
end
-- 过滤可以特殊召唤的暗属性融合怪兽：该怪兽能以给定的素材融合召唤且能特殊召唤
function s.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 过滤符合条件的对方场上融合素材：必须表侧表示、可作为融合素材、是暗属性且不受当前效果影响
function s.ffiltr(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and c:IsFusionAttribute(ATTRIBUTE_DARK)
		and (not e or not c:IsImmuneToEffect(e))
end
-- ②效果的发动准备与目标检查（Target函数）：收集双方场上的暗属性融合素材，判断是否存在可进行融合召唤的暗属性融合怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取己方场上符合条件的暗属性融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取对方场上符合条件的暗属性融合素材
		local mg2=Duel.GetMatchingGroup(s.ffiltr,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 判断自己额外卡组是否存在可以包含这张卡在内的素材融合召唤的暗属性融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 通过连锁素材效果判断是否存在可以融合召唤的暗属性融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		return res and c:IsAttribute(ATTRIBUTE_DARK)
	end
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理（Operation函数）：选择1只可以进行融合召唤的暗属性融合怪兽，玩家选择包含这张卡在内的双方场上暗属性怪兽作为素材送去墓地，并进行融合召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 获取己方场上符合条件的暗属性融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取对方场上符合条件的暗属性融合素材
	local mg2=Duel.GetMatchingGroup(s.ffiltr,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 获取自己额外卡组中能够融合召唤的所有合法的暗属性融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 利用连锁素材效果获取额外卡组中能够融合召唤的所有合法的暗属性融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给玩家提示：选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用场上的素材进行正规融合召唤，或决定是否使用连锁素材的效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合召唤所需的融合素材（必须包含这张卡本身）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材因效果作为融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的特殊召唤处理与送去墓地处理不视为同时进行
			Duel.BreakEffect()
			-- 将选择的暗属性融合怪兽融合召唤特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材效果时，让玩家选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
