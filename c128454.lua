--EMスプリングース
-- 效果：
-- 「娱乐伙伴 弹簧鹅」的效果1回合只能使用1次。
-- ①：自己主要阶段把墓地的这张卡除外，从自己的灵摆区域的「魔术师」卡、「娱乐伙伴」卡以及自己场上的灵摆怪兽之中以2张为对象才能发动。那2张卡回到持有者手卡。
function c128454.initial_effect(c)
	-- 效果原文内容：「娱乐伙伴 弹簧鹅」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(128454,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,128454)
	-- 规则层面操作：将此卡除外作为cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c128454.thtg)
	e1:SetOperation(c128454.thop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：定义可返回手卡的卡片过滤条件
function c128454.thfilter(c)
	return ((c:IsLocation(LOCATION_PZONE) and c:IsSetCard(0x9f,0x98))
		or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_PENDULUM))) and c:IsAbleToHand()
end
-- 规则层面操作：定义效果的目标选择函数
function c128454.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c128454.thfilter(chkc) end
	-- 规则层面操作：判断是否满足发动条件，即场上是否存在2张符合条件的卡
	if chk==0 then return Duel.IsExistingTarget(c128454.thfilter,tp,LOCATION_ONFIELD,0,2,nil) end
	-- 规则层面操作：向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 规则层面操作：选择2张符合条件的场上卡片作为效果对象
	local g=Duel.SelectTarget(tp,c128454.thfilter,tp,LOCATION_ONFIELD,0,2,2,nil)
	-- 规则层面操作：设置连锁的操作信息，表明将有2张卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 规则层面操作：定义效果的处理函数
function c128454.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：筛选出与当前效果相关的对象卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==2 then
		-- 规则层面操作：将符合条件的卡片送回持有者手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
