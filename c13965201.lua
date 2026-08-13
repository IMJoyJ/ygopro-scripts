--逢華妖麗譚－不知火語
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上有怪兽存在的场合，从手卡丢弃1只不死族怪兽才能发动。从自己的卡组·墓地选和丢弃的怪兽卡名不同的1只「不知火」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c13965201.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方场上有怪兽存在的场合，从手卡丢弃1只不死族怪兽才能发动。从自己的卡组·墓地选和丢弃的怪兽卡名不同的1只「不知火」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
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
-- 效果发动条件判定函数：确认对方场上存在怪兽时，该魔法卡才满足发动条件。
function c13965201.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上主要怪兽区域是否存在怪兽（数量大于0）。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 代价判定：将效果标签设为100作为已进行代价判断的标记；chk==0时直接返回true表示代价可以支付（实际丢弃手卡的操作在target阶段完成）。
function c13965201.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 代价滤卡条件：从手卡选择1只可以丢弃的不死族怪兽，且自己的卡组·墓地存在1只卡名与它不同、可特殊召唤的「不知火」怪兽。
function c13965201.costfilter(c,e,tp)
	return c:IsDiscardable() and c:IsRace(RACE_ZOMBIE)
		-- 检查自己的卡组·墓地是否存在1只与待丢弃怪兽卡名不同、且满足特殊召唤条件的「不知火」怪兽。
		and Duel.IsExistingMatchingCard(c13965201.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 特殊召唤对象的滤卡条件：该卡是「不知火」怪兽，效果处理时可以被自己特殊召唤，并且卡名与丢弃的怪兽不同。
function c13965201.spfilter(c,e,tp,code)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end
-- 发动时的目标及处理：先确认主怪兽区有空位且手卡存在可丢弃的不死族怪兽，然后选择1张手卡不死族怪兽丢弃，并登记从卡组·墓地特殊召唤1只「不知火」怪兽的操作信息。
function c13965201.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己的主要怪兽区域是否有可用空格，用于后续特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 同时检查自己的手卡中是否存在1张满足丢弃条件（可丢弃、不死族、且卡组/墓地有对应可特殊召唤的不同名「不知火」怪兽）的卡。
			and Duel.IsExistingMatchingCard(c13965201.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 向玩家发送选择丢弃手卡的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1张满足costfilter条件的卡，作为将要丢弃的代价卡。
	local g=Duel.SelectMatchingCard(tp,c13965201.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的手卡送去墓地，作为发动效果的代价（丢弃）。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	-- 登记操作信息：本效果将进行1只怪兽的特殊召唤，检索范围为卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从自己的卡组·墓地选择1只满足条件的「不知火」怪兽特殊召唤；之后适用直到回合结束时自己不能特殊召唤不死族以外怪兽的限制。
function c13965201.activate(e,tp,eg,ep,ev,re,r,rp)
	local dc=e:GetLabelObject()
	-- 获取自己的卡组·墓地中所有不受王家长眠之谷影响、且满足spfilter条件的「不知火」怪兽（与丢弃怪兽卡名不同、可特殊召唤）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c13965201.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,dc:GetCode())
	-- 如果存在符合条件的特殊召唤对象，且自己的主要怪兽区域有空位，则继续进行特殊召唤。
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家发送选择要特殊召唤的卡的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的「不知火」怪兽以表侧表示特殊召唤到自己的场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c13965201.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果（不能特殊召唤不死族以外的怪兽）注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件判定：被特殊召唤的怪兽不是不死族时，禁止该特殊召唤。
function c13965201.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
