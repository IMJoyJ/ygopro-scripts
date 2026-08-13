--Kozmo－ドッグファイター
-- 效果：
-- ①：自己·对方的准备阶段才能发动。在自己场上把1只「DOG战斗机衍生物」（机械族·暗·6星·攻2000/守2400）特殊召唤。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以下的「星际仙踪」怪兽特殊召唤。
function c29491334.initial_effect(c)
	-- ①：自己·对方的准备阶段才能发动。在自己场上把1只「DOG战斗机衍生物」（机械族·暗·6星·攻2000/守2400）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29491334,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetTarget(c29491334.tktg)
	e1:SetOperation(c29491334.tkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以下的「星际仙踪」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29491334,1))  --"从卡组把「星际仙踪」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c29491334.spcon)
	e2:SetCost(c29491334.spcost)
	e2:SetTarget(c29491334.sptg)
	e2:SetOperation(c29491334.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定：在准备阶段，检查自己怪兽区有空位且玩家可以特殊召唤DOG战斗机衍生物（机械族·暗·6星·攻2000/守2400）。
function c29491334.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够特殊召唤DOG战斗机衍生物（机械族·暗·6星·攻2000/守2400）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,29491335,0,TYPES_TOKEN_MONSTER,2000,2400,6,RACE_MACHINE,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次效果将生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的处理：实际生成并特殊召唤DOG战斗机衍生物到自己场上。
function c29491334.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时确认自己怪兽区仍有空格，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时确认玩家仍可特殊召唤该衍生物，否则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,29491335,0,TYPES_TOKEN_MONSTER,2000,2400,6,RACE_MACHINE,ATTRIBUTE_DARK) then return end
	-- 创建1只DOG战斗机衍生物（29491335）。
	local token=Duel.CreateToken(tp,29491335)
	-- 将衍生物以表侧攻击表示特殊召唤到玩家自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件：这张卡被战斗或效果破坏后送去墓地。
function c29491334.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果②的发动代价：将墓地中的这张卡除外。
function c29491334.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():IsLocation(LOCATION_GRAVE) end
	-- 将这张卡从墓地除外作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤对象的筛选条件：卡组中5星以下的「星际仙踪」怪兽且可以被特殊召唤。
function c29491334.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件与目标判定：检查怪兽区空格且卡组中存在符合条件的「星际仙踪」怪兽。
function c29491334.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足过滤条件的「星际仙踪」怪兽。
		and Duel.IsExistingMatchingCard(c29491334.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1只符合条件的「星际仙踪」怪兽并特殊召唤。
function c29491334.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时确认自己怪兽区仍有空格，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选择1张满足条件的「星际仙踪」怪兽。
	local g=Duel.SelectMatchingCard(tp,c29491334.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到玩家自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
