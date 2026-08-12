--ヒロイック・ギフト
-- 效果：
-- 对方基本分是2000以下的场合才能发动。把对方基本分变成8000并从自己卡组抽2张卡。「英豪礼物」在1回合只能发动1张。
function c95920682.initial_effect(c)
	-- 对方基本分是2000以下的场合才能发动。把对方基本分变成8000并从自己卡组抽2张卡。「英豪礼物」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,95920682+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c95920682.condition)
	e1:SetTarget(c95920682.target)
	e1:SetOperation(c95920682.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c95920682.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方的当前基本分是否在2000以下
	return Duel.GetLP(1-tp)<=2000
end
-- 定义发动时的目标确认与操作信息设置函数
function c95920682.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己是否能够抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置在效果处理时将进行抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义效果处理（发动效果）的执行函数
function c95920682.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果对方基本分已经是8000，则不进行后续处理
	if Duel.GetLP(1-tp)==8000 then return end
	-- 将对方的基本分设置为8000
	Duel.SetLP(1-tp,8000)
	-- 因效果让自己从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
end
