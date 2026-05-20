--ダーク・リペアラー
-- 效果：
-- 这张卡从自己场上送去墓地时，把自己卡组最上面的卡确认再回到卡组最上面或者最下面。
function c76614003.initial_effect(c)
	-- 这张卡从自己场上送去墓地时，把自己卡组最上面的卡确认再回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76614003,0))  --"确认卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c76614003.condition)
	e1:SetOperation(c76614003.operation)
	c:RegisterEffect(e1)
end
-- 判断这张卡是否是从自己场上送去墓地
function c76614003.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousControler(tp)
end
-- 确认自己卡组最上面的卡，并选择将其放回卡组最上面或最下面
function c76614003.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组没有卡，则不进行处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 获取自己卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	-- 让玩家确认获取到的卡
	Duel.ConfirmCards(tp,g)
	local tc=g:GetFirst()
	-- 让玩家选择将卡放回卡组最上面还是最下面
	local opt=Duel.SelectOption(tp,aux.Stringid(76614003,1),aux.Stringid(76614003,2))  --"回到卡组最上面/回到卡组最下面"
	if opt==1 then
		-- 将确认的卡移动到卡组最下面
		Duel.MoveSequence(tc,opt)
	end
end
