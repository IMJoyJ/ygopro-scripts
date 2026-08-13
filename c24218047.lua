--破面竜
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只守备力1500以下的幻龙族怪兽特殊召唤。
function c24218047.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只守备力1500以下的幻龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24218047,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c24218047.condition)
	e1:SetTarget(c24218047.target)
	e1:SetOperation(c24218047.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡因战斗破坏被送去墓地，且当前位于墓地。
function c24218047.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选条件：守备力为1500以下的幻龙族怪兽，且能够被正常特殊召唤。
function c24218047.filter(c,e,tp)
	return c:IsDefenseBelow(1500) and c:IsRace(RACE_WYRM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点判定：自己主要怪兽区有空位且卡组存在符合条件的怪兽时，效果才能发动；发动后设置从卡组特殊召唤的操作信息。
function c24218047.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查之一：自己场上存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动合法性检查之二：卡组中存在至少1张满足筛选条件的幻龙族怪兽。
		and Duel.IsExistingMatchingCard(c24218047.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：将进行从卡组特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：若自己场上仍有可用主要怪兽区域空格，则从卡组选择1只符合条件的怪兽，以表侧攻击表示特殊召唤到自己场上。
function c24218047.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时的再检查：若自己场上已没有可用主要怪兽区域空格，则本次特殊召唤处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组中选出1张满足守备力1500以下、幻龙族且可特殊召唤条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c24218047.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
