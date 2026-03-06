--ブローバック・ドラゴン
-- 效果：
-- ①：1回合1次，以对方场上1张卡为对象才能发动。进行3次投掷硬币，那之内2次以上是表的场合，那张对方的卡破坏。
function c25551951.initial_effect(c)
	-- ①：1回合1次，以对方场上1张卡为对象才能发动。进行3次投掷硬币，那之内2次以上是表的场合，那张对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25551951,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25551951.destg)
	e1:SetOperation(c25551951.desop)
	c:RegisterEffect(e1)
end
-- 选择目标卡片效果处理函数
function c25551951.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否有满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一张对方场上的卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，指定将进行3次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 效果发动时的处理函数
function c25551951.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 进行3次硬币投掷，返回3个结果
		local c1,c2,c3=Duel.TossCoin(tp,3)
		if c1+c2+c3<2 then return end
		-- 若硬币正面次数大于等于2，则破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
