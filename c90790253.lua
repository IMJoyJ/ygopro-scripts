--リトル・ウィンガード
-- 效果：
-- 这张卡在自己的结束阶段时可以变更表示形式1次。
function c90790253.initial_effect(c)
	-- 这张卡在自己的结束阶段时可以变更表示形式1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90790253,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c90790253.poscon)
	e1:SetTarget(c90790253.postg)
	e1:SetOperation(c90790253.posop)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件函数，用于判断是否在自己的结束阶段
function c90790253.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果发动的目标确认函数
function c90790253.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，表示该效果会改变自身（1张卡）的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 定义效果运行的具体操作函数
function c90790253.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡改变表示形式（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
