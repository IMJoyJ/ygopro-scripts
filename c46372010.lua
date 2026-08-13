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
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从卡组把1只「DD」怪兽加入手卡。
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
-- 定义检索过滤条件：只有卡名含有DD、且为怪兽卡、且能被加入手卡的卡才符合条件。
function c46372010.filter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设置函数：在发动时确认卡组存在符合条件的DD怪兽，并告知系统此效果将把1张卡加入手卡。
function c46372010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足filter条件的DD怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c46372010.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息为：从持有者tp的卡组将1张卡加入手卡（目标数1），供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时的实际执行函数：从卡组选出1张DD怪兽加入手卡，并展示给对方。
function c46372010.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家弹出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中挑选1张满足filter条件的DD怪兽。
	local g=Duel.SelectMatchingCard(tp,c46372010.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去其持有者的手卡，即加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚才加入手卡的卡，确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件判定函数：仅在当前回合玩家是自己（即自己的准备阶段）时才满足条件。
function c46372010.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为这张卡的持有者/控制者tp，以确保只在己方准备阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的目标设置函数：无特殊对象要求，定义伤害对象和伤害值并写入连锁信息。
function c46372010.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设置为tp，即承受伤害的玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的对象参数设置为1000，即准备阶段要受到的伤害数值。
	Duel.SetTargetParam(1000)
	-- 设置本连锁的操作信息为：对tp造成1000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- ②效果处理时的实际执行函数：从连锁信息中取出对象玩家和伤害数值并实际造成伤害。
function c46372010.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象玩家p和伤害数值d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成d点伤害，即自己受到1000伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
