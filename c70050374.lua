--ツインバレル・ドラゴン
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，选择对方场上存在的1张卡发动。进行2次投掷硬币，2次都是表的场合，选择的卡破坏。
function c70050374.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，选择对方场上存在的1张卡发动。进行2次投掷硬币，2次都是表的场合，选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70050374,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c70050374.destg)
	e1:SetOperation(c70050374.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果的目标选择与操作信息设置函数
function c70050374.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 给玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息为投掷2次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,2)
end
-- 效果处理的执行函数，进行投硬币并根据结果破坏对象卡
function c70050374.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 让玩家进行2次投掷硬币并获取结果
		local c1,c2=Duel.TossCoin(tp,2)
		if c1+c2<2 then return end
		-- 将对象卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
