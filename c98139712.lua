--死霊の誘い
-- 效果：
-- 每次送卡去墓地，每1张卡、那些卡的主人基本分受到300的伤害。
function c98139712.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次送卡去墓地，每1张卡、那些卡的主人基本分受到300的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c98139712.operation)
	c:RegisterEffect(e2)
end
-- 过滤出送去墓地的卡片中持有者为对方的卡
function c98139712.filter1(c,tp)
	return c:GetOwner()==1-tp
end
-- 过滤出送去墓地的卡片中持有者为己方的卡
function c98139712.filter2(c,tp)
	return c:GetOwner()==tp
end
-- 计算双方送去墓地的卡片数量，并分别给予对应的伤害
function c98139712.operation(e,tp,eg,ep,ev,re,r,rp)
	local d1=eg:FilterCount(c98139712.filter1,nil,tp)*300
	local d2=eg:FilterCount(c98139712.filter2,nil,tp)*300
	-- 给予对方玩家其送去墓地的卡片数量×300的伤害（分步处理）
	Duel.Damage(1-tp,d1,REASON_EFFECT,true)
	-- 给予自身玩家其送去墓地的卡片数量×300的伤害（分步处理）
	Duel.Damage(tp,d2,REASON_EFFECT,true)
	-- 完成伤害流程，触发对应的时点
	Duel.RDComplete()
end
