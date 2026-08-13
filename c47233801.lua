--黒蛇病
-- 效果：
-- 每到自己的准备阶段，这张卡对双方玩家造成200点伤害。2个回合以后，每到自己的准备阶段，这个伤害都会加倍。
function c47233801.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每到自己的准备阶段，这张卡对双方玩家造成200点伤害。2个回合以后，每到自己的准备阶段，这个伤害都会加倍。
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
-- 伤害效果的发动条件：仅当这张卡的控制者处于自己的准备阶段时才满足（当前回合玩家等于控制者），从而保证效果在自己的准备阶段触发。
function c47233801.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者，若是则条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- 效果发动时的目标处理：该伤害效果不取对象，因此直接允许发动，并设置操作信息为对双方玩家造成伤害。
function c47233801.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果处理的操作信息：分类为伤害，对象为双方玩家（PLAYER_ALL），表示将对双方玩家造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 效果处理：通过标志效果获取并更新当前伤害值（首次为200，之后每次翻倍），然后对控制者和对方玩家各造成等量伤害。
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
	-- 以效果原因对这张卡的控制者造成当前伤害值的伤害（is_step=true表示作为连续处理的一步）。
	Duel.Damage(tp,dam,REASON_EFFECT,true)
	-- 以效果原因对对方玩家造成当前伤害值的伤害（is_step=true）。
	Duel.Damage(1-tp,dam,REASON_EFFECT,true)
	-- 完成伤害处理步骤，触发与伤害相关的时点；因为前面的Duel.Damage使用了is_step=true，需要调用此函数通告伤害处理完毕。
	Duel.RDComplete()
end
