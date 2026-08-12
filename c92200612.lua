--霊魂鳥－伝鳩
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：1回合1次，以这张卡以外的场上1只灵魂怪兽为对象才能发动。那只怪兽回到持有者手卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c92200612.initial_effect(c)
	-- 注册灵魂怪兽在召唤·反转的回合结束阶段回到持有者手卡的共通效果。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为恒假，使这张卡不能被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以这张卡以外的场上1只灵魂怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92200612,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c92200612.thtg)
	e2:SetOperation(c92200612.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上可以回到手牌的灵魂怪兽。
function c92200612.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end
-- ①号效果的发动准备与对象选择。
function c92200612.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c92200612.cfilter(chkc) end
	-- 检查场上是否存在除自身以外可以回到手牌的灵魂怪兽作为合法对象。
	if chk==0 then return Duel.IsExistingTarget(c92200612.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择1只除自身以外的灵魂怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c92200612.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置操作信息为将选中的1张卡送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①号效果的效果处理。
function c92200612.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽因效果送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
