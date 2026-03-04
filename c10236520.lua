--忍者義賊ゴエゴエ
-- 效果：
-- 对方手卡是5张以上的场合，这张卡给与对方基本分战斗伤害时，对方手卡随机丢弃2张。
function c10236520.initial_effect(c)
	-- 对方手卡是5张以上的场合，这张卡给与对方基本分战斗伤害时，对方手卡随机丢弃2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10236520,0))  --"手牌丢弃"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c10236520.condition)
	e1:SetTarget(c10236520.target)
	e1:SetOperation(c10236520.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，用于检查是否满足诱发时机和条件。
function c10236520.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查受到伤害的是对方玩家且对方手牌数量在5张以上。
	return ep~=tp and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=5
end
-- 定义效果目标函数，用于设置操作信息和确认处理可行性。
function c10236520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为手牌丢弃类别，目标玩家为对方，预计处理数量为2张。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end
-- 定义效果处理函数，执行实际的手牌随机丢弃操作。
function c10236520.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家手牌区域的所有卡片组成卡片组。
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()<5 then return end
	local sg=g:RandomSelect(1-tp,2)
	-- 将随机选择的2张卡以效果和丢弃原因送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end
