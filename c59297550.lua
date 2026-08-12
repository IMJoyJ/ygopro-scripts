--ゼンマイマジシャン
-- 效果：
-- 「发条魔术师」以外的名字带有「发条」的怪兽的效果发动的场合，可以从自己卡组把1只名字带有「发条」的4星以下的怪兽表侧守备表示特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c59297550.initial_effect(c)
	-- 「发条魔术师」以外的名字带有「发条」的怪兽的效果发动的场合，可以从自己卡组把1只名字带有「发条」的4星以下的怪兽表侧守备表示特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59297550,0))  --"特殊召唤"
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetCondition(c59297550.spcon)
	e1:SetTarget(c59297550.sptg)
	e1:SetOperation(c59297550.spop)
	c:RegisterEffect(e1)
end
-- 检查发动效果的卡是否为「发条魔术师」以外的名字带有「发条」的怪兽
function c59297550.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsSetCard(0x58) and not re:GetHandler():IsCode(59297550)
end
-- 过滤卡组中名字带有「发条」的4星以下且可以表侧守备表示特殊召唤的怪兽
function c59297550.filter(c,e,tp)
	return c:IsSetCard(0x58) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标检查，确认自身不在连锁中、自己场上有可用怪兽区域，且卡组中存在满足条件的怪兽
function c59297550.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsStatus(STATUS_CHAINING)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c59297550.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1只满足条件的「发条」怪兽表侧守备表示特殊召唤
function c59297550.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c59297550.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
