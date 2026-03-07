--旅人の試練
-- 效果：
-- ①：对方怪兽的攻击宣言时1次，可以把这个效果发动。自己1张手卡由对方随机选，对方对那张卡的种类（怪兽·魔法·陷阱）作猜测。猜错的场合，那只攻击怪兽回到持有者手卡。
function c39537362.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：对方怪兽的攻击宣言时1次，可以把这个效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39537362,0))  --"宣言卡种"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c39537362.condition)
	e2:SetTarget(c39537362.target)
	e2:SetOperation(c39537362.activate)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断攻击方是否为对方控制的怪兽
function c39537362.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断攻击方是否为对方控制的怪兽
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果原文内容：自己1张手卡由对方随机选，对方对那张卡的种类（怪兽·魔法·陷阱）作猜测。
function c39537362.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查自己手牌是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 规则层面作用：将攻击怪兽设置为效果目标
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 效果原文内容：猜错的场合，那只攻击怪兽回到持有者手卡。
function c39537362.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查自己手牌是否为0
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		-- 规则层面作用：检查攻击怪兽是否仍然存在于场上
		or not Duel.GetAttacker():IsRelateToEffect(e) then return end
	-- 规则层面作用：从自己手牌中随机选择一张牌交给对方
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):RandomSelect(1-tp,1)
	local tc=g:GetFirst()
	-- 规则层面作用：提示对方选择卡的种类
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 规则层面作用：让对方宣言卡的种类
	local op=Duel.AnnounceType(1-tp)
	-- 规则层面作用：向对方展示所选手牌
	Duel.ConfirmCards(1-tp,tc)
	-- 规则层面作用：洗切自己的手牌
	Duel.ShuffleHand(tp)
	if (op~=0 and tc:IsType(TYPE_MONSTER)) or (op~=1 and tc:IsType(TYPE_SPELL)) or (op~=2 and tc:IsType(TYPE_TRAP)) then
		-- 规则层面作用：将攻击怪兽送回持有者手牌
		Duel.SendtoHand(Duel.GetAttacker(),nil,REASON_EFFECT)
	end
end
