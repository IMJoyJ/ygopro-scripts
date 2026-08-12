--奇跡の発掘
-- 效果：
-- ①：除外的自己怪兽5只以上存在的场合，以那之内3只为对象才能发动。那些怪兽回到墓地。
function c6343408.initial_effect(c)
	-- ①：除外的自己怪兽5只以上存在的场合，以那之内3只为对象才能发动。那些怪兽回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c6343408.condition)
	e1:SetTarget(c6343408.target)
	e1:SetOperation(c6343408.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的怪兽
function c6343408.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 发动条件判定
function c6343408.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己被除外的怪兽是否存在5只以上
	return Duel.IsExistingMatchingCard(c6343408.filter,tp,LOCATION_REMOVED,0,5,nil)
end
-- 效果发动时的对象选择与处理准备
function c6343408.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c6343408.filter(chkc) end
	-- 在发动阶段，检查自己被除外的怪兽中是否存在至少3只可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c6343408.filter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要回到墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(6343408,0))  --"请选择要回到墓地的卡"
	-- 选择自己被除外的3只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6343408.filter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息：将选中的3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,3,0,0)
end
-- 效果处理的执行
function c6343408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将这些怪兽以回到墓地的形式送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
