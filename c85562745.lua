--悪夢の拷問部屋
-- 效果：
-- ①：每次「噩梦之拷问室」以外的卡的效果让对方受到伤害发动。给与对方300伤害。
function c85562745.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「噩梦之拷问室」以外的卡的效果让对方受到伤害发动。给与对方300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85562745,0))  --"给对方300伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c85562745.con)
	e2:SetTarget(c85562745.tg)
	e2:SetOperation(c85562745.op)
	c:RegisterEffect(e2)
end
-- 检查触发条件：受到伤害的是对方、该伤害不是战斗伤害、存在伤害来源的效果且该效果的卡片不是「噩梦之拷问室」
function c85562745.con(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_BATTLE)==0 and re and not re:GetHandler():IsCode(85562745)
end
-- 设置效果发动的目标与操作信息：将对方设为伤害对象，数值设为300，并注册伤害操作信息
function c85562745.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害数值）设置为300
	Duel.SetTargetParam(300)
	-- 设置当前连锁的操作信息为：给与对方玩家300点效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 效果处理：获取当前连锁设定的目标玩家和伤害数值，并给与该玩家对应的效果伤害
function c85562745.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁中设定的目标玩家和参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
