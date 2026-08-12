--ヴァレル・リブート
-- 效果：
-- 这张卡也能把基本分支付一半从手卡发动。
-- ①：自己场上有「弹丸」怪兽或「枪管」怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效，那张卡直接盖放。这个效果盖放的卡在这个回合不能发动。
local s,id,o=GetID()
-- 注册卡片效果：①效果（无效魔陷发动并盖放）以及手卡发动效果。
function s.initial_effect(c)
	-- ①：自己场上有「弹丸」怪兽或「枪管」怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效，那张卡直接盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把基本分支付一半从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCost(s.cost)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「枪管重启」的效果来发动"
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「弹丸」怪兽或「枪管」怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x102,0x10f)
end
-- 效果①的发动条件：对方发动魔陷且可被无效，同时自己场上存在「弹丸」或「枪管」怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的魔法·陷阱卡，且该发动可以被无效。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「弹丸」怪兽或「枪管」怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 手卡发动时的Cost处理函数：支付一半基本分。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半的基本分。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 效果①的发动准备：设置无效发动的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果①的效果处理：无效对方魔陷的发动，并将其直接盖放，该卡本回合不能发动。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 若成功无效发动，且该卡在连锁中、可以盖放、且不是灵摆卡，则执行后续处理。
	if Duel.NegateActivation(ev) and rc:IsRelateToChain(ev) and rc:IsCanTurnSet() and not rc:IsType(TYPE_PENDULUM) then
		rc:CancelToGrave()
		-- 将该卡直接里侧表示盖放。
		Duel.ChangePosition(rc,POS_FACEDOWN)
		-- 触发盖放魔法·陷阱卡的时点。
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		-- 这个效果盖放的卡在这个回合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		rc:RegisterEffect(e1,true)
	end
end
