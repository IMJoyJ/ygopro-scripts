--トゥーン・リボルバー・ドラゴン
-- 效果：
-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ③：1回合1次，以场上1张卡为对象才能发动。进行3次投掷硬币，那之内2次以上是表的场合，那张卡破坏。
function c28112535.initial_effect(c)
	-- 记录这张卡的关联卡名「卡通世界」（15259703），用于后续相关效果判定。
	aux.AddCodeList(c,15259703)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c28112535.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c28112535.dircon)
	c:RegisterEffect(e4)
	-- ③：1回合1次，以场上1张卡为对象才能发动。进行3次投掷硬币，那之内2次以上是表的场合，那张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c28112535.destg)
	e5:SetOperation(c28112535.desop)
	c:RegisterEffect(e5)
end
-- 在召唤成功时，给这张卡自身注册一个“不能攻击”的效果，持续到回合结束。
function c28112535.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：检查卡是否为表侧表示且卡名是「卡通世界」。
function c28112535.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤函数：检查卡是否为表侧表示且种族类型为卡通怪兽。
function c28112535.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的条件：自己场上有表侧表示「卡通世界」，且对方场上不存在表侧表示卡通怪兽。
function c28112535.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上（含魔陷区）是否存在至少1张表侧表示的「卡通世界」。
	return Duel.IsExistingMatchingCard(c28112535.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方怪兽区不存在表侧表示卡通怪兽（满足cfilter2的卡）。
		and not Duel.IsExistingMatchingCard(c28112535.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- ③的发动时处理：选择场上1张卡作为对象，并设置相关操作信息（投硬币3次）。
function c28112535.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上是否存在至少1张可以成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象（取对象）。
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果包含投硬币，预计投掷3次。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- ③的效果处理：取得对象卡，投掷3次硬币，若2次以上为表侧则破坏该卡。
function c28112535.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让当前玩家投掷3次硬币，返回3个结果（1为正面，0为反面）。
		local c1,c2,c3=Duel.TossCoin(tp,3)
		if c1+c2+c3<2 then return end
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
