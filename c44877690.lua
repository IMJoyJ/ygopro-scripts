--氷結界の神精霊
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。自己场上有其他的「冰结界」怪兽存在的场合，作为代替把以下效果发动。
-- ●这张卡召唤·反转的回合的结束阶段，以对方场上1只怪兽为对象发动。那只对方怪兽回到手卡。
function c44877690.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。自己场上有其他的「冰结界」怪兽存在的场合，作为代替把以下效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c44877690.retreg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 创建一个在结束阶段触发的效果，用于使该怪兽返回手卡。
function c44877690.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●这张卡召唤·反转的回合的结束阶段，以对方场上1只怪兽为对象发动。那只对方怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	e1:SetCondition(c44877690.retcon)
	-- 设置该效果的目标为自身，强制返回手牌。
	e1:SetTarget(aux.SpiritReturnTargetForced)
	-- 设置该效果的操作为将自身返回手牌。
	e1:SetOperation(aux.SpiritReturnOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- 设置该效果的目标为可选返回手牌。
	e2:SetTarget(aux.SpiritReturnTargetOptional)
	c:RegisterEffect(e2)
	-- 创建一个在结束阶段触发的效果，用于将对方怪兽返回手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetDescription(1104)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	e3:SetCondition(c44877690.retcon2)
	e3:SetTarget(c44877690.rettg2)
	e3:SetOperation(c44877690.retop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在其他「冰结界」怪兽。
function c44877690.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 判断是否满足返回手牌的条件，若存在其他「冰结界」怪兽则不返回，否则根据效果类型决定是否返回。
function c44877690.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上存在其他「冰结界」怪兽，则不返回手牌。
	if Duel.IsExistingMatchingCard(c44877690.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return false end
	if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
		-- 若为强制返回效果，则调用强制返回条件函数。
		return aux.SpiritReturnConditionForced(e,tp,eg,ep,ev,re,r,rp)
	else
		-- 若为可选返回效果，则调用可选返回条件函数。
		return aux.SpiritReturnConditionOptional(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 判断是否满足发动替代效果的条件，即场上存在其他「冰结界」怪兽。
function c44877690.retcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在其他「冰结界」怪兽。
	return Duel.IsExistingMatchingCard(c44877690.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 设置选择对方场上怪兽返回手牌的目标。
function c44877690.rettg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上一只可返回手牌的怪兽作为目标。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明将要处理的卡为对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行将对方怪兽返回手牌的操作。
function c44877690.retop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsControler(1-tp) and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
