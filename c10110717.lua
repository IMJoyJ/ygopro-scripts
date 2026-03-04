--メカウサー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只「机械兔」在自己场上里侧守备表示特殊召唤。这张卡反转时，选择场上存在的1张卡，给与那个控制者500分伤害。
function c10110717.initial_effect(c)
	-- 创建诱发选发效果：这张卡被战斗破坏送去墓地时，可以从自己卡组把1只「机械兔」在自己场上里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10110717,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c10110717.condition)
	e1:SetTarget(c10110717.target)
	e1:SetOperation(c10110717.operation)
	c:RegisterEffect(e1)
	-- 创建诱发必发效果：这张卡反转时，选择场上存在的1张卡，给与那个控制者500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10110717,1))  --"伤害"
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c10110717.damtg)
	e2:SetOperation(c10110717.damop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否因战斗破坏而送入墓地
function c10110717.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义过滤器函数，用于筛选可以特殊召唤的「机械兔」
function c10110717.filter(c,e,tp)
	return c:IsCode(10110717) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 设置特殊召唤效果的目标阶段处理逻辑
function c10110717.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在满足条件的「机械兔」
		and Duel.IsExistingMatchingCard(c10110717.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表明将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤的操作处理
function c10110717.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区域没有空位，则终止操作
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从卡组中选择1只符合条件的「机械兔」
	local g=Duel.SelectMatchingCard(tp,c10110717.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 以里侧守备表示形式将选中的「机械兔」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对手展示刚刚特殊召唤的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置伤害效果的目标阶段处理逻辑
function c10110717.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 提示玩家选择伤害效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 让玩家选择场上的1张卡作为伤害效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 设置操作信息，表明将对对象的控制者造成500点伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,g:GetFirst():GetControler(),500)
	end
end
-- 执行造成伤害的操作处理
function c10110717.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 对目标卡的控制者造成500点效果伤害
		Duel.Damage(tc:GetControler(),500,REASON_EFFECT)
	end
end
