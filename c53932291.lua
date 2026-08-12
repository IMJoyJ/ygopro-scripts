--SRタケトンボーグ
-- 效果：
-- 自己对「疾行机人 竹蜻蜓电子人」1回合只能有1次特殊召唤。
-- ①：自己场上有风属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。从卡组把1只「疾行机人」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c53932291.initial_effect(c)
	c:SetSPSummonOnce(53932291)
	-- ①：自己场上有风属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c53932291.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从卡组把1只「疾行机人」调整特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53932291,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c53932291.spcost)
	e2:SetTarget(c53932291.sptg)
	e2:SetOperation(c53932291.spop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的风属性怪兽
function c53932291.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 检查自身特殊召唤规则的条件是否满足（怪兽区域有空位且场上有风属性怪兽）
function c53932291.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的风属性怪兽
		and Duel.IsExistingMatchingCard(c53932291.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 检查并执行发动效果的代价（解放自身）
function c53932291.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「疾行机人」调整怪兽
function c53932291.filter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查特殊召唤效果的发动条件并设置操作信息
function c53932291.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因解放自身，空位数需大于等于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足条件的「疾行机人」调整怪兽
		and Duel.IsExistingMatchingCard(c53932291.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置在效果处理时从卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组特殊召唤「疾行机人」调整怪兽，并适用特殊召唤限制的效果处理
function c53932291.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足条件的「疾行机人」调整怪兽
		local g=Duel.SelectMatchingCard(tp,c53932291.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c53932291.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤风属性怪兽（非风属性怪兽不能特殊召唤）
function c53932291.splimit(e,c,tp,sumtp,sumpos)
	return c:GetAttribute()~=ATTRIBUTE_WIND
end
