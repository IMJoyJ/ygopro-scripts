--仮面竜
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的龙族怪兽特殊召唤。
function c39191307.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39191307,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c39191307.condition)
	e1:SetTarget(c39191307.target)
	e1:SetOperation(c39191307.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：这张卡在墓地且被战斗破坏（即满足“被战斗破坏送去墓地时”的发动时机）。
function c39191307.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选卡组中满足攻击力1500以下、龙族且能够被特殊召唤的怪兽。
function c39191307.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标合法检查：确认主要怪兽区有空位，且卡组中存在符合条件的龙族怪兽可被特殊召唤。
function c39191307.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否存在空位，以此作为能否发动特殊召唤的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足c39191307.filter条件的怪兽，作为能否发动特殊召唤的条件之一。
		and Duel.IsExistingMatchingCard(c39191307.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 为当前连锁设置操作信息，声明本效果将进行特殊召唤，预定从卡组特殊召唤1只怪兽（处理时再确定对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若主要怪兽区仍有空位，则让玩家从卡组选择1只符合条件的龙族怪兽，并以表侧表示特殊召唤到己方场上。
function c39191307.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区是否有空位，若没有空位则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求其选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选择1张符合filter条件的龙族怪兽（作为特殊召唤的对象）。
	local g=Duel.SelectMatchingCard(tp,c39191307.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
