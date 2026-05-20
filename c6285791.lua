--邪悪なるワーム・ビースト
-- 效果：
-- ①：自己结束阶段发动。场上的表侧表示的这张卡回到持有者手卡。
function c6285791.initial_effect(c)
	-- ①：自己结束阶段发动。场上的表侧表示的这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6285791,0))  --"返回手牌"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c6285791.retcon)
	e1:SetTarget(c6285791.rettg)
	e1:SetOperation(c6285791.retop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数，用于判断是否满足发动时机
function c6285791.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡片的控制者（自己）
	return Duel.GetTurnPlayer()==tp
end
-- 定义效果的发动目标函数，作为必发效果直接允许发动，并设置将自身返回手牌的操作信息
function c6285791.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果的处理是将自身（1张卡）送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 定义效果的运行函数，在卡片与效果有联系且呈表侧表示时，将其送回持有者手牌
function c6285791.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 通过效果将这张卡送回持有者的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
