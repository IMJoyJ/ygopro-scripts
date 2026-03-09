--黒蛇病
-- 效果：
-- 每到自己的准备阶段，这张卡对双方玩家造成200点伤害。2个回合以后，每到自己的准备阶段，这个伤害都会加倍。
function c47233801.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 为黑蛇病卡注册一个诱发必发效果，用于在准备阶段对双方造成伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47233801,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c47233801.damcon)
	e2:SetTarget(c47233801.damtg)
	e2:SetOperation(c47233801.damop)
	c:RegisterEffect(e2)
end
-- 判断是否为当前回合玩家的准备阶段
function c47233801.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 设置该效果的处理信息，表明将造成伤害
function c47233801.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将要处理的是伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 处理黑蛇病的伤害效果，根据回合数决定伤害值并造成伤害
function c47233801.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dam=c:GetFlagEffectLabel(47233801)
	if dam==nil then
		c:RegisterFlagEffect(47233801,RESET_EVENT+RESETS_STANDARD,0,0,200)
		dam=200
	else
		dam=dam*2
		c:SetFlagEffectLabel(47233801,dam)
	end
	-- 对当前回合玩家造成指定伤害值
	Duel.Damage(tp,dam,REASON_EFFECT,true)
	-- 对非当前回合玩家造成指定伤害值
	Duel.Damage(1-tp,dam,REASON_EFFECT,true)
	-- 完成伤害处理流程，触发相关时点效果
	Duel.RDComplete()
end
