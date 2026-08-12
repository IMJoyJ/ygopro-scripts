--フィッシュアンドキックス
-- 效果：
-- 从游戏中除外的自己的鱼族·海龙族·水族怪兽有3只以上的场合，选择场上存在的1张卡发动。选择的卡从游戏中除外。
function c32703716.initial_effect(c)
	-- 创建效果，设置为发动时点、取对象、除外类别效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c32703716.condition)
	e1:SetTarget(c32703716.target)
	e1:SetOperation(c32703716.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在表侧表示的鱼族·海龙族·水族怪兽
function c32703716.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 条件函数，判断自己除外区是否有3只以上鱼族·海龙族·水族怪兽
function c32703716.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组，检查除外区是否存在3只以上符合条件的怪兽
	return Duel.IsExistingMatchingCard(c32703716.cfilter,tp,LOCATION_REMOVED,0,3,nil)
end
-- 目标选择函数，选择场上1张可除外的卡作为目标
function c32703716.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查是否满足发动条件，确认场上存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张可除外的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息，记录本次效果将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 发动函数，将目标卡从游戏中除外
function c32703716.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示形式从游戏中除外，原因来自效果
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
