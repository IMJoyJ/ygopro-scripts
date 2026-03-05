--リチュア・アバンス
-- 效果：
-- 1回合1次，可以从自己卡组选择1只名字带有「遗式」的怪兽在卡组最上面放置。
function c16693254.initial_effect(c)
	-- 效果原文：1回合1次，可以从自己卡组选择1只名字带有「遗式」的怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16693254,0))  --"卡组最上方放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c16693254.target)
	e1:SetOperation(c16693254.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：名字带有「遗式」的怪兽
function c16693254.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER)
end
-- 效果作用：检查自己卡组是否存在满足条件的卡片
function c16693254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查以玩家tp来看的自己卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16693254.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果作用：选择并移动卡片到卡组最上方
function c16693254.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：向玩家tp发送提示信息“请选择要放置到卡组最上方的卡”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16693254,1))  --"请选择要放置到卡组最上方的卡"
	-- 规则层面：让玩家tp从自己卡组选择1张满足filter条件的卡
	local g=Duel.SelectMatchingCard(tp,c16693254.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面：洗切玩家tp的卡组
		Duel.ShuffleDeck(tp)
		-- 规则层面：将目标卡片移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 规则层面：确认玩家tp卡组最上方1张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
