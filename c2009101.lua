--BF－疾風のゲイル
-- 效果：
-- ①：自己场上有「黑羽-疾风之盖尔」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力变成一半。
function c2009101.initial_effect(c)
	-- 效果原文内容：①：自己场上有「黑羽-疾风之盖尔」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c2009101.spcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2009101,0))  --"攻防减半"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c2009101.target)
	e2:SetOperation(c2009101.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义过滤函数，用于判断场上是否存在满足条件的「黑羽」怪兽（非盖尔本人且表侧表示）。
function c2009101.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(2009101)
end
-- 规则层面作用：判断特殊召唤条件是否满足，即玩家场上存在空位且有至少一只非盖尔的「黑羽」怪兽。
function c2009101.spcon(e,c)
	if c==nil then return true end
	-- 规则层面作用：检查玩家场上是否有足够的主怪兽区域用于特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 规则层面作用：确认玩家场上是否存在至少一只满足过滤条件的「黑羽」怪兽。
		Duel.IsExistingMatchingCard(c2009101.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：定义效果目标选择函数，用于选择对方场上的表侧表示怪兽作为对象。
function c2009101.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 规则层面作用：检查是否满足发动条件，即对方场上是否存在至少一只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：向玩家发送提示信息，提示其选择对方场上的表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面作用：执行选择对方场上表侧表示怪兽的操作。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 规则层面作用：定义效果发动时的处理函数，将目标怪兽的攻守值减半。
function c2009101.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果原文内容：那只对方怪兽的攻击力·守备力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
		-- 效果原文内容：那只对方怪兽的攻击力·守备力变成一半。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		tc:RegisterEffect(e2)
	end
end
