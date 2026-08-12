--ジュラック・ヴェロー
-- 效果：
-- ①：自己场上的攻击表示的这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1700以下的「朱罗纪」怪兽特殊召唤。
function c59312550.initial_effect(c)
	-- ①：自己场上的攻击表示的这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1700以下的「朱罗纪」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59312550,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c59312550.condition)
	e1:SetTarget(c59312550.target)
	e1:SetOperation(c59312550.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡在自己场上以表侧攻击表示存在，被战斗破坏并送去墓地
function c59312550.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsPreviousPosition(POS_FACEUP_ATTACK) and c:IsPreviousControler(tp)
end
-- 过滤条件：卡组中攻击力1700以下的「朱罗纪」怪兽，且可以被特殊召唤
function c59312550.filter(c,e,tp)
	return c:IsSetCard(0x22) and c:IsAttackBelow(1700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查怪兽区域是否有空位，以及卡组中是否存在符合条件的怪兽
function c59312550.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c59312550.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：在连锁处理中确定要从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的「朱罗纪」怪兽，以表侧表示特殊召唤
function c59312550.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足过滤条件的「朱罗纪」怪兽
	local g=Duel.SelectMatchingCard(tp,c59312550.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
