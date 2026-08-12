--エレキングコブラ
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击给与对方基本分战斗伤害时，从自己卡组把1只名字带有「电气」的怪兽加入手卡。
function c88205593.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，从自己卡组把1只名字带有「电气」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88205593,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c88205593.condition)
	e2:SetTarget(c88205593.target)
	e2:SetOperation(c88205593.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数
function c88205593.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的玩家是对方，且攻击对象为空（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 过滤卡组中属于「电气」字段且可以加入手牌的怪兽卡
function c88205593.filter(c)
	return c:IsSetCard(0xe) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果发动时的目标处理函数
function c88205593.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果运行空间，执行检索「电气」怪兽加入手牌的操作
function c88205593.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端弹出提示信息，提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c88205593.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
