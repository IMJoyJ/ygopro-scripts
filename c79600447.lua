--メメント・クレニアム・バースト
-- 效果：
-- 这个卡名的②的效果在同一连锁上只能发动1次。
-- ①：可以攻击的对方怪兽只要自己场上有「莫忘」怪兽存在，必须向那之内的攻击力最高的怪兽作出攻击。
-- ②：对方把场上的怪兽的效果发动时，以自己场上1只「冥骸合龙-莫忘冥地王灵」为对象才能发动。那只怪兽的攻击力·守备力下降1000，那个发动的效果无效。
local s,id,o=GetID()
-- 定义并注册卡片的所有效果，包括卡片发动、强制攻击、强制攻击特定怪兽以及无效对方怪兽效果的二速效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：可以攻击的对方怪兽只要自己场上有「莫忘」怪兽存在，必须向那之内的攻击力最高的怪兽作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.macon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atklimit)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果在同一连锁上只能发动1次。②：对方把场上的怪兽的效果发动时，以自己场上1只「冥骸合龙-莫忘冥地王灵」为对象才能发动。那只怪兽的攻击力·守备力下降1000，那个发动的效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- 过滤函数：用于筛选自己场上表侧表示的「莫忘」怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- 强制攻击效果的适用条件：自己场上存在「莫忘」怪兽
function s.macon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「莫忘」怪兽
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制攻击目标：判断被攻击的怪兽是否为自己场上攻击力最高的「莫忘」怪兽
function s.atklimit(e,c)
	-- 获取自己场上表侧表示的「莫忘」怪兽中攻击力最高的一组怪兽
	local g=Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	return g and g:IsContains(c)
end
-- 过滤函数：用于筛选自己场上表侧表示、且攻击力和守备力都在1000以上的「冥骸合龙-莫忘冥地王灵」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(23288411) and c:IsAttackAbove(1000) and c:IsDefenseAbove(1000)
end
-- 效果发动条件：对方在场上发动怪兽效果，且该效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动的、可以被无效的怪兽效果，若不是则返回false
	if rp~=1-tp or not (re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)) then return false end
	-- 获取当前连锁中效果发动时的所在位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return loc&LOCATION_MZONE>0
end
-- 效果发动时的对象选择与操作信息注册
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 在发动时检查自己场上是否存在符合条件的「冥骸合龙-莫忘冥地王灵」作为对象
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「冥骸合龙-莫忘冥地王灵」作为效果的对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表明该效果包含无效效果的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：使作为对象的怪兽攻守下降1000，并无效对方发动的效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackAbove(1000) and tc:IsDefenseAbove(1000))
		or tc:IsImmuneToEffect(e) then return end
	-- 那只怪兽的攻击力·守备力下降1000
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-1000)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
	if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 无效该连锁中对方发动的效果
		Duel.NegateEffect(ev)
	end
end
