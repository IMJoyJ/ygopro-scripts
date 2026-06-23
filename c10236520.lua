--忍者義賊ゴエゴエ
-- 效果：
-- 对方手卡是5张以上的场合，这张卡给与对方基本分战斗伤害时，对方手卡随机丢弃2张。
function c10236520.initial_effect(c)
	-- 对方手卡是5张以上的场合，这张卡给与对方基本分战斗伤害时，对方手卡随机丢弃2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10236520,0))  --"手牌丢弃"
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c10236520.condition)
	e1:SetTarget(c10236520.target)
	e1:SetOperation(c10236520.operation)
	c:RegisterEffect(e1)
end
-- 判断是否给与对方战斗伤害且对方手卡在5张以上
function c10236520.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 受到伤害的是对方，且对方手卡数量在5张以上
	return ep~=tp and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=5
end
-- 效果发动的目标：设置丢弃对方手牌的操作信息
function c10236520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方丢弃2张手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,2)
end
-- 效果处理：从对方手牌随机选择2张丢弃
function c10236520.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到伤害的玩家（对方）的手卡
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()<5 then return end
	local sg=g:RandomSelect(1-tp,2)
	-- 将选中的卡因效果丢弃送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end
