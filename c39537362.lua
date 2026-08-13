--旅人の試練
-- 效果：
-- ①：对方怪兽的攻击宣言时1次，可以把这个效果发动。自己1张手卡由对方随机选，对方对那张卡的种类（怪兽·魔法·陷阱）作猜测。猜错的场合，那只攻击怪兽回到持有者手卡。
function c39537362.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽的攻击宣言时1次，可以把这个效果发动。自己1张手卡由对方随机选，对方对那张卡的种类（怪兽·魔法·陷阱）作猜测。猜错的场合，那只攻击怪兽回到持有者手卡。
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
-- 效果发动条件：判断攻击怪兽是否为对方（1-tp）控制的怪兽。
function c39537362.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前攻击怪兽的控制者是对方则条件成立（本卡效果只在对方攻击宣言时才能发动）。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 发动时的效果目标处理：确认自己手牌有1张以上，并把攻击怪兽登记为与效果关联的卡片。
function c39537362.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查（chk==0）：要求自己手牌至少有1张，否则无法发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 将攻击怪兽设为当前连锁的效果对象，用于之后判断其是否仍与效果关联。
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 效果处理前的条件复核：若自己手牌已没有卡，或攻击怪兽与效果已失去关联，则终止处理。
function c39537362.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己手牌数量为0，则不再执行后续效果。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		-- 若攻击怪兽已经不处于与这个效果关联的状态（例如已离场或效果无效等），则不再执行后续效果。
		or not Duel.GetAttacker():IsRelateToEffect(e) then return end
	-- 从自己手牌中随机选择1张卡（由对方随机选）。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):RandomSelect(1-tp,1)
	local tc=g:GetFirst()
	-- 向对方发出选择卡片种类的提示信息。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让对方宣言一个卡片种类（怪兽/魔法/陷阱），返回值op对应0/1/2。
	local op=Duel.AnnounceType(1-tp)
	-- 将随机选出的手牌给对手确认。
	Duel.ConfirmCards(1-tp,tc)
	-- 确认后洗切自己的手牌，避免对手根据位置猜测手牌。
	Duel.ShuffleHand(tp)
	if (op~=0 and tc:IsType(TYPE_MONSTER)) or (op~=1 and tc:IsType(TYPE_SPELL)) or (op~=2 and tc:IsType(TYPE_TRAP)) then
		-- 在对方猜错的情况下，将那只攻击怪兽返回持有者手卡。
		Duel.SendtoHand(Duel.GetAttacker(),nil,REASON_EFFECT)
	end
end
