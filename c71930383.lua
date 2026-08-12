--パトロイド
-- 效果：
-- 把对方场上盖放的1张卡翻开，确认后回到原状。这个效果1回合只有1次在自己的主要阶段才能发动。
function c71930383.initial_effect(c)
	-- 把对方场上盖放的1张卡翻开，确认后回到原状。这个效果1回合只有1次在自己的主要阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71930383,0))  --"确认盖卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c71930383.target)
	e1:SetOperation(c71930383.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与判定函数
function c71930383.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFacedown() end
	-- 在发动阶段，检查对方场上是否存在至少1张里侧表示的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择里侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方场上1张里侧表示的卡片作为效果对象
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理的执行函数
function c71930383.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将目标卡片给发动效果的玩家确认
		Duel.ConfirmCards(tp,tc)
	end
end
