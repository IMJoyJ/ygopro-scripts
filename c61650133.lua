--召喚の呪詛
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段支付500基本分。或者不支付500基本分让这张卡破坏。这张卡在场上存在的场合怪兽特殊召唤成功时，那些怪兽的控制者选择1张手卡从游戏中除外。
function c61650133.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己的结束阶段支付500基本分。或者不支付500基本分让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61650133,0))  --"是否要支付500基本分维持「召唤的诅咒」？"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c61650133.mtcon)
	e2:SetOperation(c61650133.mtop)
	c:RegisterEffect(e2)
	-- 这张卡在场上存在的场合怪兽特殊召唤成功时，那些怪兽的控制者选择1张手卡从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61650133,1))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c61650133.rmtg)
	e3:SetOperation(c61650133.rmop)
	c:RegisterEffect(e3)
end
-- 维持代价效果的发动条件函数（仅在自己的结束阶段）
function c61650133.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为这张卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价效果的操作函数（选择支付500基本分或破坏此卡）
function c61650133.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否能支付500基本分，并由控制者选择是否支付
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(61650133,0)) then  --"是否要支付500基本分维持「召唤的诅咒」？"
		-- 控制者支付500基本分
		Duel.PayLPCost(tp,500)
	else
		-- 因未支付维持代价而破坏这张卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 特殊召唤成功时除外手牌效果的发动检查函数
function c61650133.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 特殊召唤成功时除外手牌效果的操作函数（判断特殊召唤怪兽的控制者并让其选择手牌除外）
function c61650133.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rm1=false
	local rm2=false
	local tc=eg:GetFirst()
	while tc do
		if tc:IsOnField() then
			if tc:IsControler(tp) then rm1=true else rm2=true end
		end
		tc=eg:GetNext()
	end
	local g=Group.CreateGroup()
	if rm1 then
		-- 给自身玩家发送选择除外卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 自身玩家从手牌选择1张可以除外的卡
		local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		g:Merge(g1)
	end
	if rm2 then
		-- 给对方玩家发送选择除外卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 对方玩家从手牌选择1张可以除外的卡
		local g2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemove,1-tp,LOCATION_HAND,0,1,1,nil)
		g:Merge(g2)
	end
	-- 将选中的手牌表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
