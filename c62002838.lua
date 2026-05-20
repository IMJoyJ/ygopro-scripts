--闇と消滅の竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组把1只龙族·8星怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是龙族怪兽不能特殊召唤。
-- ②：可以从以下效果选择1个发动。
-- ●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ●以场上1只其他的攻击表示怪兽为对象才能发动。这张卡的攻击力·守备力下降500，作为对象的怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤，②融合召唤或降低攻守并破坏怪兽
function s.initial_effect(c)
	-- ①：从额外卡组把1只龙族·8星怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.ftg)
	e2:SetOperation(s.fop)
	c:RegisterEffect(e2)
	-- ●以场上1只其他的攻击表示怪兽为对象才能发动。这张卡的攻击力·守备力下降500，作为对象的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.fusion_effect=true
-- 过滤条件：额外卡组中可以作为Cost除外的8星龙族怪兽
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(8) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的Cost：从额外卡组将1只8星龙族怪兽除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查额外卡组是否存在满足条件的龙族·8星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择额外卡组中1只满足条件的龙族·8星怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的Target：检查怪兽区域空格以及自身是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation：特殊召唤自身，并适用“这个回合自己不是龙族怪兽不能特殊召唤”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是龙族怪兽不能特殊召唤。/●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。/●以场上1只其他的攻击表示怪兽为对象才能发动。这张卡的攻击力·守备力下降500，作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.spelimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册该回合的特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤龙族怪兽
function s.spelimit(e,c)
	return not c:IsRace(RACE_DRAGON)
end
-- 过滤条件：不受当前效果影响的怪兽（用于融合素材过滤）
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以使用指定素材进行融合召唤的融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的Target：检查是否存在可融合召唤的怪兽并设置操作信息
function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在可以使用手卡·场上素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果适用下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的Operation：选择融合怪兽，决定素材并送去墓地，进行融合召唤
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取不受此效果影响的卡以外的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取使用手卡·场上素材可以融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规的手卡·场上素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择用于融合召唤的常规素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽进行融合召唤特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家选择使用连锁素材效果时的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：场上表侧表示且处于攻击表示的怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsPosition(POS_ATTACK)
end
-- 降低攻守并破坏怪兽效果的Target：检查并选择场上1只其他的攻击表示怪兽作为对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and s.atkfilter(chkc) end
	-- 检查自身攻击力与守备力是否都在500以上，且场上是否存在其他攻击表示怪兽
	if chk==0 then return c:IsAttackAbove(500) and c:IsDefenseAbove(500) and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只其他的攻击表示怪兽作为效果对象
	local tc=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置破坏操作的信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 降低攻守并破坏怪兽效果的Operation：自身攻击力·守备力下降500，并将作为对象的怪兽破坏
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAttackAbove(500) and c:IsDefenseAbove(500) then
		-- 这张卡的攻击力·守备力下降500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
			-- 将作为对象的怪兽破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
