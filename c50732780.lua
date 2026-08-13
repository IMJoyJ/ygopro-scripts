--ヘル・セキュリティ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。从卡组把1只恶魔族·1星怪兽特殊召唤。
function c50732780.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。从卡组把1只恶魔族·1星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50732780,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c50732780.condition)
	e1:SetTarget(c50732780.target)
	e1:SetOperation(c50732780.operation)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：这张卡位于墓地，且是因战斗破坏而被送去墓地。
function c50732780.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义特殊召唤对象的筛选条件：必须是恶魔族且等级为1，并且能被当前效果特殊召唤。
function c50732780.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的处理：本效果不需要取对象，直接允许发动；同时登记本次连锁将执行从卡组特殊召唤的操作。
function c50732780.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组特殊召唤1只怪兽（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若我方主要怪兽区有空位，则从卡组选择1只符合条件的恶魔族·1星怪兽，以表侧表示特殊召唤到我方场上。
function c50732780.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方主要怪兽区是否有空位，若没有剩余空位则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组中筛选并选择1张满足filter条件的恶魔族·1星怪兽卡（可被特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c50732780.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择到的怪兽以表侧表示特殊召唤到自己的场上（不无视召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
