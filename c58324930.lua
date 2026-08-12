--破戒僧 ランシン
-- 效果：
-- 这张卡被对方从场上送去墓地时，选择对方墓地存在的1只怪兽从游戏中除外。
function c58324930.initial_effect(c)
	-- 这张卡被对方从场上送去墓地时，选择对方墓地存在的1只怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58324930,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c58324930.condition)
	e1:SetTarget(c58324930.target)
	e1:SetOperation(c58324930.operation)
	c:RegisterEffect(e1)
end
-- 检查触发条件：此卡之前存在于场上且由自身控制，因对方的操作被送去墓地
function c58324930.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousControler(tp) and rp==1-tp
end
-- 过滤条件：对方墓地中可以被除外的怪兽卡
function c58324930.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动时的对象选择：若有符合条件的对象则进行选择，并设置除外操作信息
function c58324930.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c58324930.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地存在的1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58324930.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：在效果处理时将对方墓地的该卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理：将发动时选择的对象怪兽从游戏中除外
function c58324930.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
