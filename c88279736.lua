--追い剥ぎゴブリン
-- 效果：
-- 自己场上的怪兽每次造成对方玩家的战斗伤害时，对方随机丢弃1张手卡。
function c88279736.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽每次造成对方玩家的战斗伤害时，对方随机丢弃1张手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88279736,0))  --"对方随机丢弃1张手牌"
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c88279736.condition)
	e2:SetTarget(c88279736.target)
	e2:SetOperation(c88279736.operation)
	c:RegisterEffect(e2)
end
-- 判断触发条件：受到战斗伤害的玩家是对方，造成伤害的怪兽控制者是自己，且此卡已在场上表侧表示存在。
function c88279736.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():GetControler()==tp and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果发动的目标确认，必发效果直接返回true，并设置丢弃手牌的操作信息。
function c88279736.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：对方玩家丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 效果处理：获取对方手牌并随机选择1张，以丢弃和效果原因送去墓地。
function c88279736.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到伤害的玩家（对方）的所有手牌。
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	local sg=g:RandomSelect(ep,1)
	-- 将随机选中的手牌以丢弃和效果原因送去墓地。
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
