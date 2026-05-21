--磁石の戦士Σ－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。包含手卡的这张卡的自己的手卡·场上的岩石族怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只8星「磁石战士」怪兽送去墓地。
-- ③：1回合1次，双方的地属性怪兽之间进行战斗的攻击宣言时才能发动。那次攻击无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤、召唤/特殊召唤时送墓、攻击无效三个效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。包含手卡的这张卡的自己的手卡·场上的岩石族怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.fspcost)
	e1:SetTarget(s.fsptg)
	e1:SetOperation(s.fspop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只8星「磁石战士」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，双方的地属性怪兽之间进行战斗的攻击宣言时才能发动。那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"攻击无效"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 融合召唤效果的Cost，检查手卡的这张卡是否未给对方观看
function s.fspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 融合素材过滤条件：岩石族怪兽且不受该效果影响
function s.spfilter1(c,e)
	return c:IsRace(RACE_ROCK) and not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤条件：融合怪兽、可以特殊召唤，且能以包含指定卡（手卡的这张卡）在内的素材进行融合召唤
function s.spfilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 融合召唤效果的Target，检查是否存在可融合召唤的怪兽并设置特殊召唤的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材中满足岩石族条件的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
		-- 检查额外卡组是否存在可以使用包含这张卡在内的素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的Operation，执行融合素材的选择、送去墓地以及融合怪兽的特殊召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 获取玩家可用的融合素材中满足岩石族条件的卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
	-- 获取额外卡组中可以使用包含这张卡在内的素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，额外卡组中可融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给玩家发送提示信息，提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若可以使用常规素材，且不选择使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择包含这张卡在内的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材作为融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送墓同时进行
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在连锁素材效果下，让玩家选择包含这张卡在内的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：卡名含有「磁石战士」且等级为8、可以送去墓地的怪兽
function s.tgfilter(c)
	return c:IsSetCard(0xe9) and c:IsLevel(8) and c:IsAbleToGrave()
end
-- 送墓效果的Target，检查卡组中是否存在满足条件的怪兽并设置送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地的操作信息，表示将从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送墓效果的Operation，从卡组选择1只满足条件的怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 攻击无效效果的Condition，检查进行战斗的双方怪兽是否都是表侧表示的地属性怪兽
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（攻击目标）
	local b=Duel.GetAttackTarget()
	return a and a:IsFaceup() and a:IsAttribute(ATTRIBUTE_EARTH)
		and b and b:IsFaceup() and b:IsAttribute(ATTRIBUTE_EARTH)
end
-- 攻击无效效果的Operation，使本次攻击无效
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效本次攻击
	Duel.NegateAttack()
end
