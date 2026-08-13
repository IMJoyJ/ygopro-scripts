--プレイ・ザ・ディアベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法·陷阱卡为让卡的效果发动而被送去墓地的场合才能发动。从手卡·卡组·额外卡组把1只幻想魔族·魔法师族怪兽送去墓地。
-- ②：自己主要阶段，从自己墓地把包含这张卡的3张魔法·陷阱卡除外才能发动。从自己的手卡·墓地把1只「迪亚贝尔」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：为卡片注册两个效果——e1为①的诱发效果（魔法·陷阱卡为发动效果而被送墓时，从手卡·卡组·额外卡组把1只幻想魔族·魔法师族怪兽送去墓地），e2为②的起动效果（自己主要阶段除外包含本卡的3张魔法·陷阱卡，从手卡·墓地特殊召唤1只「迪亚贝尔」怪兽）；分别设置种类、范围、条件/代价、目标与处理，并各自附加1回合1次限制。
function s.initial_effect(c)
	-- ①：魔法·陷阱卡为让卡的效果发动而被送去墓地的场合才能发动。从手卡·卡组·额外卡组把1只幻想魔族·魔法师族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送墓效果"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段，从自己墓地把包含这张卡的3张魔法·陷阱卡除外才能发动。从自己的手卡·墓地把1只「迪亚贝尔」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定被送去墓地的卡是否属于“魔法·陷阱卡为让卡的效果发动而被送去墓地”——要求该卡原始类型为魔法·陷阱卡，且存在已发动/激活的效果（或属于陷阱手牌发动、陷阱盖放回合发动、速攻魔法/陷阱对方回合手牌发动等特殊发动规则）。
function s.cfilter(c,re)
	if c:GetOriginalType()&(TYPE_SPELL+TYPE_TRAP)==0 or not re then return false end
	local recode=re:GetCode()
	return re:IsActivated()
		or recode==EFFECT_TRAP_ACT_IN_HAND
		or recode==EFFECT_TRAP_ACT_IN_SET_TURN
		or recode==EFFECT_QP_ACT_IN_NTPHAND
		or recode==EFFECT_QP_ACT_IN_SET_TURN
end
-- 效果①的发动条件：本次被送去墓地的卡组eg中存在满足cfilter的魔法·陷阱卡，且送墓原因包含REASON_COST（作为发动效果的代价被送墓）。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_COST>0 and eg:IsExists(s.cfilter,1,nil,re)
end
-- 送墓对象的过滤条件：对象必须是怪兽卡，且种族为幻想魔族或魔法师族，并且可以送去墓地。
function s.tgfilter(c)
	return c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的发动目标判定：在发动时检查手卡·卡组·额外卡组是否存在1只可送墓的幻想魔族·魔法师族怪兽；若存在则登记操作信息，本效果将把1只该范围内的卡送去墓地。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：从手卡·卡组·额外卡组中是否存在满足tgfilter的至少1张怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：将本效果处理时送去墓地的卡的范围登记为手卡+卡组+额外卡组，数量为1（由于不取对象，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果①处理：效果结算时从手卡·卡组·额外卡组中选择1只幻想魔族·魔法师族怪兽送入墓地。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示：选择要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡·卡组·额外卡组中筛选并选择1张满足送墓条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以效果原因（REASON_EFFECT）送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 除外代价的过滤条件：卡的类型为魔法或陷阱，且能够作为代价从墓地除外。
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价判定：确认本卡自身能够从墓地除外，并且墓地中存在2张可除外的其他魔法·陷阱卡（合计3张）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c = e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 判定墓地中是否存在除自身以外至少2张满足rmfilter的魔法·陷阱卡，以供作为代价。
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,2,c) end
	-- 向操作玩家显示选择提示：选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择2张（除自身外）满足条件的魔法·陷阱卡作为除外代价。
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,2,2,c)
	g:AddCard(c)
	-- 将选中的2张魔法·陷阱卡与本卡一同以表侧表示除外（REASON_COST），完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤对象的过滤条件：卡名属于「迪亚贝尔」系列（0x19b），且该卡能够被特殊召唤（符合召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x19b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标判定：确认我方主要怪兽区有空位，并且手卡/墓地中存在可特殊召唤的「迪亚贝尔」怪兽；同时登记操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：我方主要怪兽区是否至少存在1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地中是否存在至少1只满足spfilter（「迪亚贝尔」系列且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：登记本效果处理时将从手卡/墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②处理：若我方主要怪兽区仍有空位，则从手卡/墓地选择1只「迪亚贝尔」怪兽（并排除因王家长眠之谷等不能从墓地特殊召唤的情况），将其表侧表示特殊召唤到我的场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认我方主要怪兽区仍有空位，保证特殊召唤的可行性。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作玩家显示选择提示：选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡/墓地中选择1只符合条件的「迪亚贝尔」怪兽，并使用NecroValleyFilter过滤受王家长眠之谷影响而无法特殊召唤的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到我的场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
