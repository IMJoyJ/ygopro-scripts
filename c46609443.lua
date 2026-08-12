--カオスエンドマスター
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以从卡组把1只5星以上而攻击力1600以下的怪兽特殊召唤。
function c46609443.initial_effect(c)
	-- 创建一个诱发选发效果，当己方怪兽战斗破坏对方怪兽时发动，效果描述为“特殊召唤”，分类为特殊召唤，触发事件为战斗破坏送去墓地，生效位置为主怪兽区
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46609443,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c46609443.spcon)
	e1:SetTarget(c46609443.sptg)
	e1:SetOperation(c46609443.spop)
	c:RegisterEffect(e1)
end
-- 判断被战斗破坏的怪兽是否为己方怪兽（即该怪兽是被己方怪兽战斗破坏），并且该怪兽在墓地且是因为战斗破坏而进入墓地
function c46609443.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 过滤函数，用于筛选攻击力不超过1600、等级不低于5、可以被特殊召唤的怪兽
function c46609443.filter(c,e,tp)
	return c:IsAttackBelow(1600) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：己方场上存在空位，并且卡组中存在满足条件的怪兽
function c46609443.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c46609443.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只来自卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的操作：若场上存在空位，则提示选择并特殊召唤一只符合条件的怪兽
function c46609443.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查己方场上是否还有空位，如果没有则不执行后续操作
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c46609443.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
