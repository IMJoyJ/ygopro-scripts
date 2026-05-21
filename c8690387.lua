--地縛戒隷 ジオグレムリン
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以对方场上1只表侧表示怪兽为对象才能发动。对方从以下选1个，自己让那个效果适用。
-- ●作为对象的怪兽破坏。
-- ●自己基本分回复作为对象的怪兽的攻击力的数值。
-- ②：自己·对方的战斗阶段才能发动。自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只「地缚」融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、①效果（主要阶段选1个适用）和②效果（战斗阶段融合召唤）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：暗属性调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	-- ①：自己·对方的主要阶段，以对方场上1只表侧表示怪兽为对象才能发动。对方从以下选1个，自己让那个效果适用。●作为对象的怪兽破坏。●自己基本分回复作为对象的怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.rdcon)
	e1:SetTarget(s.rdtg)
	e1:SetOperation(s.rdop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段才能发动。自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只「地缚」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.fscon)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己·对方的主要阶段
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- ①效果的靶向/发动准备：以对方场上1只表侧表示怪兽为对象
function s.rdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果的处理：对方从两个选项中选择一个，自己让那个效果适用（破坏或回复生命值）
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 让对方玩家从两个选项中选择一个
	local op=aux.SelectFromOptions(1-tp,
		{true,aux.Stringid(id,2)},  --"那只怪兽破坏"
		{aux.nzatk(tc),aux.Stringid(id,3)})  --"对方回复那只怪兽攻击力数值的基本分"
	if op==1 then
		-- 破坏作为对象的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	else
		-- 自己回复作为对象的怪兽的攻击力数值的基本分
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- ②效果的发动条件：自己·对方的战斗阶段
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 融合素材过滤条件：可以被除外且不受当前效果影响
function s.mfilter(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 融合召唤目标怪兽过滤条件：额外卡组的「地缚」融合怪兽，且能用给定的素材进行融合召唤
function s.sfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x21) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 墓地融合素材过滤条件：墓地的怪兽，且可以作为融合素材并能被除外
function s.gfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and s.mfilter(c,e)
end
-- ②效果的发动准备：检查是否存在可融合召唤的「地缚」融合怪兽并设置操作信息
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取手卡·场上可用于除外融合的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
			-- 加上墓地中可用于除外融合的怪兽
			+Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_GRAVE,0,nil,e)
		-- 检查额外卡组是否存在可以使用上述素材进行融合召唤的「地缚」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在适用的「连锁素材」等卡片效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在「连锁素材」等效果下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息（从墓地、手卡、场上除外卡片）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD)
end
-- ②效果的处理：选择1只「地缚」融合怪兽，将手卡·场上·墓地的怪兽作为素材除外，进行融合召唤
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡·场上可用于除外融合的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
		-- 加上墓地中可用于除外融合的怪兽
		+Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中可以使用上述素材进行融合召唤的「地缚」融合怪兽
	local sg1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 检查是否存在适用的「连锁素材」等卡片效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在「连锁素材」等效果下可融合召唤的怪兽
		sg2=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 判断是否使用常规的融合素材进行融合召唤（而非「连锁素材」等效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从手卡·场上·墓地中选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat<2 then goto cancel end
			tc:SetMaterial(mat)
			-- 将选作融合素材的怪兽表侧表示除外
			Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与除外同时处理
			Duel.BreakEffect()
			-- 将融合怪兽表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在「连锁素材」等效果适用下，让玩家选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat<2 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
end
