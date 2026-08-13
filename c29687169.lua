--魔装戦士 アルニス
-- 效果：
-- ①：这张卡被对方怪兽的攻击破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的魔法师族怪兽攻击表示特殊召唤。
function c29687169.initial_effect(c)
	-- ①：这张卡被对方怪兽的攻击破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的魔法师族怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29687169,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c29687169.condition)
	e1:SetTarget(c29687169.target)
	e1:SetOperation(c29687169.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：此卡位于墓地且因战斗破坏送入墓地，并且破坏它的攻击怪兽为对方控制（满足“被对方怪兽的攻击破坏送去墓地”）。
function c29687169.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		-- 确认攻击者为对方控制的怪兽（1-tp即对方），保证破坏来源是对方怪兽的攻击。
		and Duel.GetAttacker():IsControler(1-tp)
end
-- 定义特殊召唤对象的筛选条件：攻击力1500以下、魔法师族、且能被当前效果以表侧攻击表示特殊召唤。
function c29687169.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动合法性检查：自己场上主要怪兽区存在可用空格，且卡组中存在满足筛选条件的怪兽，才允许发动。
function c29687169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段先检查自己主要怪兽区的空位数是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再检查卡组中是否存在至少1只满足特殊召唤条件的怪兽（攻击力1500以下、魔法师族、可被攻击表示特召）。
		and Duel.IsExistingMatchingCard(c29687169.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：效果将从卡组特殊召唤1只怪兽（目标暂不确定，属于特殊召唤类效果）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：若仍有空位则从卡组选择符合条件的怪兽并攻击表示特殊召唤。
function c29687169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己怪兽区有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送“选择要特殊召唤的卡”的提示信息，供玩家在选择卡牌时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选出1张符合过滤条件的怪兽卡作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c29687169.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到己方场上（不忽略召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
