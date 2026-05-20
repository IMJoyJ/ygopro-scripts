--機皇兵スキエル・アイン
-- 效果：
-- 这张卡的攻击力上升这张卡以外的场上表侧表示存在的名字带有「机皇」的怪兽数量×200的数值。这张卡被战斗破坏送去墓地时，可以从自己卡组把1只名字带有「机皇兵」的怪兽特殊召唤。
function c75733063.initial_effect(c)
	-- 这张卡的攻击力上升这张卡以外的场上表侧表示存在的名字带有「机皇」的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c75733063.val)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只名字带有「机皇兵」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75733063,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c75733063.condition)
	e2:SetTarget(c75733063.target)
	e2:SetOperation(c75733063.operation)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的名字带有「机皇」的怪兽
function c75733063.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 计算攻击力上升数值的辅助函数，返回场上除自身以外表侧表示的「机皇」怪兽数量×200
function c75733063.val(e,c)
	-- 获取双方场上除自身以外满足条件的「机皇」怪兽数量并乘以200
	return Duel.GetMatchingGroupCount(c75733063.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)*200
end
-- 判断此卡是否在墓地且是因为战斗被破坏
function c75733063.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中可以特殊召唤的名字带有「机皇兵」的怪兽
function c75733063.filter(c,e,tp)
	return c:IsSetCard(0x6013) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标，在发动阶段检查自己场上是否有空怪兽位，以及卡组中是否存在可特殊召唤的「机皇兵」怪兽
function c75733063.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己卡组中是否存在至少1只满足条件的「机皇兵」怪兽
		and Duel.IsExistingMatchingCard(c75733063.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果的处理包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组选择1只「机皇兵」怪兽在自己场上特殊召唤
function c75733063.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有可用的怪兽区域空格，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组中选择1只满足条件的「机皇兵」怪兽
	local g=Duel.SelectMatchingCard(tp,c75733063.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
