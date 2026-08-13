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
-- 发动时的目标选择函数：检查是否存在合法对象，选择对方场上1张卡作为对象，并设置投掷3次硬币的操作信息。
function c25551951.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 若在效果发动时点（chk==0）检查是否存在至少1张对方场上的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家tp显示“请选择要破坏的卡”的提示，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果包含投掷3次硬币（CATEGORY_COIN），由tp投掷。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 效果处理函数：取得对象，确认对象仍与效果关联后，投掷3次硬币，若正面次数不少于2则破坏对象。
function c25551951.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 玩家tp投掷3次硬币，c1、c2、c3分别表示三次结果（1为正面，0为反面）。
		local c1,c2,c3=Duel.TossCoin(tp,3)
		if c1+c2+c3<2 then return end
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
