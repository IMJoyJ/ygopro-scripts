--地獄門の契約書
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只「DD」怪兽加入手卡。
-- ②：自己准备阶段发动。自己受到1000伤害。
function c46372010.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从卡组把1只「DD」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46372010,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,46372010)
	e2:SetTarget(c46372010.thtg)
	e2:SetOperation(c46372010.thop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c46372010.damcon)
	e3:SetTarget(c46372010.damtg)
	e3:SetOperation(c46372010.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「DD」怪兽（怪兽类型且可加入手牌）
function c46372010.filter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时点，检查是否满足检索条件并设置操作信息
function c46372010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在至少1张符合条件的「DD」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46372010.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并确认卡片
function c46372010.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c46372010.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 伤害触发条件函数，判断是否为自己的准备阶段
function c46372010.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果处理时点，设置目标玩家和伤害值
function c46372010.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息的伤害值为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息：对当前玩家造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 伤害效果处理函数，执行造成伤害
function c46372010.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对指定玩家造成相应伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
