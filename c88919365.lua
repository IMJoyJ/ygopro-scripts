--ヴァリアンツの武者－北条
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：场地区域有「群豪世界-真罗万象」存在的场合或者自己场上有水属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：以魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张卡回到持有者手卡。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从自己的手卡·场上把「群豪」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
function c88919365.initial_effect(c)
	-- 记录这张卡的效果中记载了「群豪世界-真罗万象」的卡名。
	aux.AddCodeList(c,49568943)
	-- 启用灵摆怪兽的灵摆召唤及灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：场地区域有「群豪世界-真罗万象」存在的场合或者自己场上有水属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,88919365)
	e1:SetCondition(c88919365.spcon)
	e1:SetTarget(c88919365.sptg)
	e1:SetOperation(c88919365.spop)
	c:RegisterEffect(e1)
	-- ①：以魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,88919366)
	e2:SetTarget(c88919365.thtg)
	e2:SetOperation(c88919365.thop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。从自己的手卡·场上把「群豪」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,88919367)
	e3:SetCondition(c88919365.mvcon)
	e3:SetTarget(c88919365.mvtg)
	e3:SetOperation(c88919365.mvop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的水属性「群豪」怪兽。
function c88919365.cfilter(c)
	return c:IsSetCard(0x17d) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 灵摆效果发动的条件判断函数。
function c88919365.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场地区域是否有「群豪世界-真罗万象」存在，或者自己场上是否存在水属性「群豪」怪兽。
	return Duel.IsEnvironment(49568943) or Duel.IsExistingMatchingCard(c88919365.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 灵摆效果特殊召唤的目标选择与合法性检查函数。
function c88919365.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果特殊召唤的实际处理函数。
function c88919365.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在正对面的自己的主要怪兽区域表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 过滤条件：魔法与陷阱区域（不含灵摆区）表侧表示且能回到手牌的卡。
function c88919365.thfilter(c)
	return c:GetSequence()<5 and c:IsFaceup() and c:IsAbleToHand()
end
-- 怪兽效果①（弹手牌）的目标选择与合法性检查函数。
function c88919365.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c88919365.thfilter(chkc) end
	-- 检查双方魔法与陷阱区域是否存在至少1张满足条件的表侧表示卡片。
	if chk==0 then return Duel.IsExistingTarget(c88919365.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择魔法与陷阱区域1张表侧表示的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c88919365.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置返回手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果①（弹手牌）的实际处理函数。
function c88919365.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 怪兽效果②（移动时融合）的发动条件判断函数。
function c88919365.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前的阶段，用于在伤害步骤中防止效果发动。
	local ph=Duel.GetCurrentPhase()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
		and ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL
end
-- 过滤条件：灵摆区域中可以作为融合素材且不受此效果影响的卡。
function c88919365.ffilter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：不受此效果影响的卡。
function c88919365.ffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以进行融合召唤的「群豪」融合怪兽。
function c88919365.ffilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x17d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 怪兽效果②（移动时融合）的目标选择与合法性检查函数。
function c88919365.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材怪兽。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 将自己灵摆区域存在的融合素材怪兽合并到可用融合素材组中。
		mg1:Merge(Duel.GetMatchingGroup(c88919365.ffilter0,tp,LOCATION_PZONE,0,nil,e))
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「群豪」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c88919365.ffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查玩家是否受到「连锁素材」等效果的影响。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在「连锁素材」等效果下，是否存在可融合召唤的「群豪」融合怪兽。
				res=Duel.IsExistingMatchingCard(c88919365.ffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，表示从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果②（移动时融合）的实际处理函数。
function c88919365.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取手卡和场上不受此效果影响的融合素材怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c88919365.ffilter1,nil,e)
	-- 将自己灵摆区域存在的融合素材怪兽合并到可用融合素材组中。
	mg1:Merge(Duel.GetMatchingGroup(c88919365.ffilter0,tp,LOCATION_PZONE,0,nil,e))
	-- 获取额外卡组中可以使用当前素材进行融合召唤的「群豪」融合怪兽集合。
	local sg1=Duel.GetMatchingGroup(c88919365.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的「连锁素材」等效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在「连锁素材」等效果下，可以融合召唤的「群豪」融合怪兽集合。
		sg2=Duel.GetMatchingGroup(c88919365.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非「连锁素材」等效果）进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 提示玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材怪兽送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地视为同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组进行融合召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在「连锁素材」等效果下，提示玩家选择用于融合召唤的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
