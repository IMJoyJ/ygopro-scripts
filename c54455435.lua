--ガスタの巫女 ウィンダ
-- 效果：
-- 这张卡被对方怪兽的攻击破坏送去墓地时，可以从自己卡组把1只名字带有「薰风」的调整特殊召唤。
function c54455435.initial_effect(c)
	-- 这张卡被对方怪兽的攻击破坏送去墓地时，可以从自己卡组把1只名字带有「薰风」的调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54455435,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c54455435.condition)
	e1:SetTarget(c54455435.target)
	e1:SetOperation(c54455435.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件：此卡因战斗破坏送去墓地，且是被对方怪兽攻击破坏
function c54455435.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		-- 检查此卡原本控制者是否为自己、此卡是否为攻击对象，且攻击怪兽的控制者为对方
		and c:IsPreviousControler(tp) and c==Duel.GetAttackTarget() and Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：卡组中名字带有「薰风」的调整怪兽，且可以被特殊召唤
function c54455435.filter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动的目标：检查自己场上是否有空余的怪兽区域，且卡组中是否存在满足条件的怪兽
function c54455435.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c54455435.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理：从卡组选择1只满足条件的怪兽特殊召唤到自己场上
function c54455435.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有空余的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c54455435.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
