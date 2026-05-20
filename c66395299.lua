--ドッペル・ゲイナー
-- 效果：
-- 因对方场上存在的怪兽的效果受到伤害时，给与对方基本分和受到的伤害相同的伤害。
function c66395299.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 因对方场上存在的怪兽的效果受到伤害时，给与对方基本分和受到的伤害相同的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66395299,0))  --"伤害"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(c66395299.damcon)
	e2:SetTarget(c66395299.damtg)
	e2:SetOperation(c66395299.damop)
	c:RegisterEffect(e2)
end
-- 判断伤害是否由对方场上的怪兽效果造成（必须是效果伤害、效果来源卡在怪兽区且由对方控制）
function c66395299.damcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:GetHandler():IsLocation(LOCATION_MZONE) and re:GetHandler():IsControler(1-tp)
end
-- 设置效果发动的目标，将对方玩家设为目标玩家，受到的伤害值设为目标参数，并注册伤害操作信息
function c66395299.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为玩家受到的伤害值
	Duel.SetTargetParam(ev)
	-- 设置当前连锁的操作信息为给与对方玩家与受到的伤害相同数值的效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 执行效果处理，获取目标玩家和伤害数值，给与对方玩家相应的效果伤害
function c66395299.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
