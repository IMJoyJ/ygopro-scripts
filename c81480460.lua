--リボルバー・ドラゴン
-- 效果：
-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。进行3次投掷硬币，那之内2次以上是表的场合，那只怪兽破坏。
function c81480460.initial_effect(c)
	-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。进行3次投掷硬币，那之内2次以上是表的场合，那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81480460,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c81480460.destg)
	e1:SetOperation(c81480460.desop)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备阶段，用于检查发动条件、选择对象并设置操作信息
function c81480460.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为投掷3次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 效果①的效果处理阶段，进行投掷硬币并根据结果判定是否破坏对象怪兽
function c81480460.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让发动效果的玩家投掷3次硬币，并获取每次的结果（1为表，0为里）
		local c1,c2,c3=Duel.TossCoin(tp,3)
		if c1+c2+c3<2 then return end
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
