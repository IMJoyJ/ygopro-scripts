--EMオッドアイズ・ディゾルヴァー
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己的灵摆怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤，那只自己怪兽不会被那次战斗破坏。
-- ②：自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
function c46136942.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和发动灵摆卡的效果
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46136942,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c46136942.pftg)
	e1:SetOperation(c46136942.pfop)
	c:RegisterEffect(e1)
	-- ①：自己的灵摆怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤，那只自己怪兽不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46136942,1))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,46136942)
	e2:SetCondition(c46136942.spcon)
	e2:SetTarget(c46136942.sptg)
	e2:SetOperation(c46136942.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c46136942.mftg)
	e3:SetOperation(c46136942.mfop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否免疫当前效果
function c46136942.pffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断卡片是否为龙族融合怪兽且满足特殊召唤条件
function c46136942.pffilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断是否可以发动灵摆召唤效果，检查额外卡组是否存在符合条件的融合怪兽
function c46136942.pftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组（包括手牌和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在满足过滤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c46136942.pffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前受到的连锁融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁融合素材效果，则检查其对应的融合怪兽是否满足条件
				res=Duel.IsExistingMatchingCard(c46136942.pffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表示将要特殊召唤一张融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行灵摆召唤效果的操作，选择融合怪兽并进行融合召唤
function c46136942.pfop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组，并过滤掉免疫当前效果的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c46136942.pffilter1,nil,e)
	-- 从额外卡组中筛选出满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c46136942.pffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前受到的连锁融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁融合素材效果，则筛选其对应的融合怪兽
		sg2=Duel.GetMatchingGroup(c46136942.pffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用主融合召唤路径，否则使用连锁融合召唤路径
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合召唤所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 判断是否满足触发条件：攻击方为灵摆怪兽且与对方怪兽战斗
function c46136942.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	e:SetLabelObject(a)
	return a:IsControler(tp) and a:IsFaceup() and a:IsType(TYPE_PENDULUM) and a:GetControler()~=d:GetControler()
end
-- 设置特殊召唤的判定条件
function c46136942.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤并为攻击怪兽添加不被破坏效果
function c46136942.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否可以进行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=e:GetLabelObject()
		if not tc:IsRelateToBattle() then return end
		-- 为攻击怪兽添加不被战斗破坏的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：判断卡片是否可作为融合素材且未免疫当前效果
function c46136942.mffilter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断卡片是否在场上且未免疫当前效果
function c46136942.mffilter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断卡片是否为融合怪兽且满足特殊召唤条件
function c46136942.mffilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 判断是否可以发动主要阶段的融合召唤效果，检查额外卡组是否存在符合条件的融合怪兽
function c46136942.mftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组（仅限场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 合并灵摆区域中的可作为融合素材的卡片
		mg1:Merge(Duel.GetMatchingGroup(c46136942.mffilter0,tp,LOCATION_PZONE,0,nil,e))
		-- 检查额外卡组中是否存在满足过滤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c46136942.mffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取当前受到的连锁融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁融合素材效果，则检查其对应的融合怪兽是否满足条件
				res=Duel.IsExistingMatchingCard(c46136942.mffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表示将要特殊召唤一张融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行主要阶段融合召唤效果的操作，选择融合怪兽并进行融合召唤
function c46136942.mfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取玩家可用的融合素材组，并过滤掉免疫当前效果的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c46136942.mffilter1,nil,e)
	-- 合并灵摆区域中的可作为融合素材的卡片
	mg1:Merge(Duel.GetMatchingGroup(c46136942.mffilter0,tp,LOCATION_PZONE,0,nil,e))
	-- 从额外卡组中筛选出满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c46136942.mffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前受到的连锁融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁融合素材效果，则筛选其对应的融合怪兽
		sg2=Duel.GetMatchingGroup(c46136942.mffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用主融合召唤路径，否则使用连锁融合召唤路径
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合召唤所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
