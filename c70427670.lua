--捕食植物ブフォリキュラ
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡成为融合召唤的素材，被送去墓地的场合或者表侧加入额外卡组的场合才能发动。从自己的额外卡组（表侧）把「捕食植物 土瓶草蟾蜍」以外的1只暗属性灵摆怪兽加入手卡。
local s,id,o=GetID()
-- 注册该卡的效果：①注册灵摆怪兽属性；②注册灵摆效果（融合召唤）；③注册怪兽效果（作为融合素材送去墓地或表侧加入额外卡组时，从额外卡组检索暗属性灵摆怪兽）。
function c70427670.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆卡的发动及灵摆召唤规则）。
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70427670,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,70427670)
	e1:SetTarget(c70427670.fustg)
	e1:SetOperation(c70427670.fusop)
	c:RegisterEffect(e1)
	-- ①：这张卡成为融合召唤的素材，被送去墓地的场合或者表侧加入额外卡组的场合才能发动。从自己的额外卡组（表侧）把「捕食植物 土瓶草蟾蜍」以外的1只暗属性灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70427670,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,70427670+o)
	e2:SetCondition(c70427670.thcon)
	e2:SetTarget(c70427670.thtg)
	e2:SetOperation(c70427670.thop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤条件：过滤不受效果影响的怪兽。
function c70427670.fusfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤条件：必须是暗属性融合怪兽，且可以用当前素材进行融合召唤。
function c70427670.fusfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与可行性检查：检查手卡·场上是否存在可用的融合素材，以及额外卡组是否存在可融合召唤的暗属性融合怪兽。
function c70427670.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用于融合召唤的素材卡片组（包含手卡和场上）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的暗属性融合怪兽。
		local res=Duel.IsExistingMatchingCard(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」等卡片效果）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可融合召唤的暗属性融合怪兽。
				res=Duel.IsExistingMatchingCard(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前处理的连锁操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的实际处理：让玩家选择要融合召唤的怪兽，并选择对应的融合素材送去墓地，最后进行融合召唤。
function c70427670.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤出不受当前效果影响的可用融合素材卡片组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c70427670.fusfilter1,nil,e)
	-- 获取当前素材可以融合召唤的所有暗属性融合怪兽。
	local sg1=Duel.GetMatchingGroup(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 再次获取玩家受到的连锁素材效果，用于在效果处理时进行判断。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的所有暗属性融合怪兽。
		sg2=Duel.GetMatchingGroup(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送提示信息：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不使用连锁素材效果，则执行常规融合处理）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材作为融合素材因效果送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与送去墓地不视为同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择用于融合召唤的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 检索效果的发动条件：这张卡作为融合素材被送去墓地，或者表侧表示加入额外卡组。
function c70427670.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 检索卡片的过滤条件：额外卡组中表侧表示的、除「捕食植物 土瓶草蟾蜍」以外的暗属性灵摆怪兽。
function c70427670.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM) and not c:IsCode(70427670) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查额外卡组中是否存在符合条件的卡，并设置操作信息为将卡加入手卡。
function c70427670.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组（表侧表示）是否存在至少1张满足条件的暗属性灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c70427670.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置当前处理的连锁操作信息：从额外卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 检索效果的实际处理：从额外卡组（表侧表示）选择1张符合条件的卡加入手卡。
function c70427670.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从额外卡组（表侧表示）中选择1张符合条件的暗属性灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c70427670.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
