--EMユーゴーレム
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己场上有怪兽融合召唤的场合才能发动。从自己墓地的灵摆怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选「娱乐伙伴」怪兽、「异色眼」怪兽、「魔术师」怪兽之内任意1只加入手卡。
-- 【怪兽效果】
-- ①：这张卡灵摆召唤成功的回合的自己主要阶段才能发动1次。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，其他的融合素材怪兽必须全部是龙族怪兽。
function c73511233.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己场上有怪兽融合召唤的场合才能发动。从自己墓地的灵摆怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选「娱乐伙伴」怪兽、「异色眼」怪兽、「魔术师」怪兽之内任意1只加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetCondition(c73511233.thcon)
	e1:SetTarget(c73511233.thtg)
	e1:SetOperation(c73511233.thop)
	c:RegisterEffect(e1)
	-- 这张卡灵摆召唤成功的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c73511233.effcon)
	e2:SetOperation(c73511233.regop)
	c:RegisterEffect(e2)
	-- ①：这张卡灵摆召唤成功的回合的自己主要阶段才能发动1次。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，其他的融合素材怪兽必须全部是龙族怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c73511233.spcon)
	e3:SetTarget(c73511233.sptg)
	e3:SetOperation(c73511233.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：由自己场上融合召唤成功的怪兽
function c73511233.thcfilter(c,tp)
	return c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 灵摆效果发动条件：自己场上有怪兽融合召唤成功的场合
function c73511233.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(c73511233.thcfilter,1,nil,tp)
end
-- 过滤条件：墓地或额外卡组表侧表示的「娱乐伙伴」、「异色眼」或「魔术师」灵摆怪兽，且能加入手卡
function c73511233.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x98,0x99,0x9f)
		and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果发动准备：检查是否存在可加入手卡的卡，并设置回收手卡的操作信息
function c73511233.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或额外卡组是否存在至少1张满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73511233.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置回收手卡的操作信息，预计从墓地或额外卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 灵摆效果处理：从墓地或额外卡组选择1张符合条件的卡加入手卡并给对方确认
function c73511233.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从墓地（受王家长眠之谷影响）或额外卡组选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c73511233.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查这张卡是否是通过灵摆召唤特殊召唤成功
function c73511233.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 在这张卡上注册一个持续到回合结束的标记，用于记录其在当前回合灵摆召唤成功
function c73511233.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(73511233,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 怪兽效果发动条件：这张卡在灵摆召唤成功的回合的自己主要阶段
function c73511233.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(73511233)~=0
end
-- 过滤条件：场上的龙族怪兽（用于常规融合素材检测）
function c73511233.spfilter0(c)
	return c:IsRace(RACE_DRAGON) and c:IsOnField()
end
-- 过滤条件：场上不受当前效果影响的龙族怪兽（用于融合效果处理时的素材检测）
function c73511233.spfilter1(c,e)
	return c73511233.spfilter0(c) and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以使用包含这张卡在内的素材进行融合召唤的融合怪兽
function c73511233.spfilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 过滤条件：可以作为融合素材的龙族怪兽（用于连锁素材等特殊融合效果）
function c73511233.spfilter3(c)
	return c:IsCanBeFusionMaterial() and c:IsRace(RACE_DRAGON)
end
-- 怪兽效果发动准备：检查是否能以包含这张卡且其他素材均为龙族怪兽的方式进行融合召唤，并设置特殊召唤的操作信息
function c73511233.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材中属于场上龙族怪兽的部分
		local mg1=Duel.GetFusionMaterial(tp):Filter(c73511233.spfilter0,nil)
		mg1:AddCard(c)
		-- 检查额外卡组是否存在可以使用包含这张卡在内的场上龙族怪兽作为素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c73511233.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材等特殊融合效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp):Filter(c73511233.spfilter3,nil)
				mg2:AddCard(c)
				local mf=ce:GetValue()
				-- 检查在特殊融合效果下，是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c73511233.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，预计从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果处理：将包含这张卡在内的融合素材送去墓地，从额外卡组融合召唤1只融合怪兽（其他素材必须全部是龙族怪兽）
function c73511233.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsControler(1-tp) then return end
	-- 获取玩家可用且不受当前效果影响的场上龙族怪兽作为融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c73511233.spfilter1,nil,e)
	mg1:AddCard(c)
	-- 获取可以使用包含这张卡在内的场上龙族怪兽进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c73511233.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 再次获取玩家受到的连锁素材等特殊融合效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp):Filter(c73511233.spfilter3,nil)
		mg2:AddCard(c)
		local mf=ce:GetValue()
		-- 获取在特殊融合效果下可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c73511233.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（若只能用常规融合，或玩家选择不使用特殊融合效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择包含这张卡在内的常规融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材因效果、素材、融合原因送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家从特殊融合素材组中选择包含这张卡在内的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
