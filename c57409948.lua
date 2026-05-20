--爆弾かめ虫
-- 效果：
-- 反转：确认对方场上的1张里侧守备表示的怪兽卡。如果被确认的怪兽是效果怪兽的话破坏，（反转效果不会发动），其他情况被确认卡变回原来的情况。
function c57409948.initial_effect(c)
	-- 反转：确认对方场上的1张里侧守备表示的怪兽卡。如果被确认的怪兽是效果怪兽的话破坏，（反转效果不会发动），其他情况被确认卡变回原来的情况。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57409948,0))  --"确认盖卡"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c57409948.target)
	e1:SetOperation(c57409948.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的靶向（Target）函数，用于筛选并选择对方场上1只里侧守备表示的怪兽作为效果对象
function c57409948.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向玩家发送提示，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1张里侧表示的怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理（Operation）函数，确认目标卡片，若为效果怪兽则将其破坏
function c57409948.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 让发动效果的玩家确认该里侧表示的怪兽
		Duel.ConfirmCards(tp,tc)
		if tc:IsType(TYPE_EFFECT) then
			-- 将该怪兽因效果破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
