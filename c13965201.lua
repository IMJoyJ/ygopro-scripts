--逢華妖麗譚－不知火語
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上有怪兽存在的场合，从手卡丢弃1只不死族怪兽才能发动。从自己的卡组·墓地选和丢弃的怪兽卡名不同的1只「不知火」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c13965201.initial_effect(c)
	-- ①：对方场上有怪兽存在的场合，从手卡丢弃1只不死族怪兽才能发动。从自己的卡组·墓地选和丢弃的怪兽卡名不同的1只「不知火」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13965201+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c13965201.condition)
	e1:SetCost(c13965201.cost)
	e1:SetTarget(c13965201.target)
	e1:SetOperation(c13965201.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：对方场上有怪兽存在
function c13965201.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否至少存在1只怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果代价函数：设置标签为100表示已支付代价
function c13965201.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 丢弃代价过滤器：检查手牌中是否包含可丢弃的不死族怪兽
function c13965201.costfilter(c,e,tp)
	return c:IsDiscardable() and c:IsRace(RACE_ZOMBIE)
		-- 检查在卡组或墓地中是否存在与丢弃怪兽卡名不同的「不知火」怪兽
		and Duel.IsExistingMatchingCard(c13965201.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 特殊召唤目标过滤器：筛选「不知火」怪兽且可特殊召唤
function c13965201.spfilter(c,e,tp,code)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end
-- 效果目标函数：设置效果目标
function c13965201.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查玩家场上是否有足够的特殊召唤区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手牌中是否存在满足条件的不死族怪兽用于丢弃
			and Duel.IsExistingMatchingCard(c13965201.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 提示玩家选择要丢弃的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择满足条件的1只不死族怪兽丢弃
	local g=Duel.SelectMatchingCard(tp,c13965201.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选中的怪兽送入墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	-- 设置操作信息：准备特殊召唤「不知火」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动函数：执行效果处理
function c13965201.activate(e,tp,eg,ep,ev,re,r,rp)
	local dc=e:GetLabelObject()
	-- 获取满足条件的「不知火」怪兽组（排除王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c13965201.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,dc:GetCode())
	-- 判断是否有满足条件的怪兽且场上存在召唤区域
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 发动后效果：直到回合结束时自己不是不死族怪兽不能特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c13965201.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 不能特殊召唤效果的目标过滤器：排除不死族怪兽
function c13965201.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
