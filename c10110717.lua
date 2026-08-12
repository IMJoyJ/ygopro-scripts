--メカウサー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只「机械兔」在自己场上里侧守备表示特殊召唤。这张卡反转时，选择场上存在的1张卡，给与那个控制者500分伤害。
function c10110717.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只「机械兔」在自己场上里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10110717,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c10110717.condition)
	e1:SetTarget(c10110717.target)
	e1:SetOperation(c10110717.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，选择场上存在的1张卡，给与那个控制者500分伤害。
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
-- ①效果的发动条件判断：这张卡被战斗破坏送去墓地时
function c10110717.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：卡组中可里侧守备表示特殊召唤的「机械兔」
function c10110717.filter(c,e,tp)
	return c:IsCode(10110717) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ①效果的发动准备
function c10110717.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中是否存在可以特殊召唤的「机械兔」
		and Duel.IsExistingMatchingCard(c10110717.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置从卡组特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从自己卡组把1只「机械兔」在自己场上里侧守备表示特殊召唤
function c10110717.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空怪兽区域则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中1只满足条件的「机械兔」
	local g=Duel.SelectMatchingCard(tp,c10110717.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 给对方玩家确认特殊召唤的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动准备：选择场上存在的1张卡作为对象
function c10110717.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 提示玩家选择作为对象的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上存在的1张卡作为对象并设置
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 设置给与伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,g:GetFirst():GetControler(),500)
	end
end
-- ②效果的处理：给与作为对象的卡的控制者500分伤害
function c10110717.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 给与该卡控制者500分伤害
		Duel.Damage(tc:GetControler(),500,REASON_EFFECT)
	end
end
