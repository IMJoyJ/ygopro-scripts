--罪禍の三幻魔－降雷皇ハモン
-- 效果：
-- 这张卡不能通常召唤，用「三幻魔」卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「三幻魔」魔法卡加入手卡。那之后，选自己1张手卡丢弃。
-- ②：1回合1次，怪兽被送去对方墓地的场合发动。给与对方1000伤害。
-- ③：这张卡被战斗·效果破坏的场合才能发动。这个回合，自己受到的全部伤害变成0。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括苏生限制、特殊召唤限制、手牌展示检索、给与伤害以及破坏后免伤效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「三幻魔」卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「三幻魔」魔法卡加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，怪兽被送去对方墓地的场合发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"伤害效果"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。这个回合，自己受到的全部伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"伤害免疫"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.damcon2)
	e3:SetOperation(s.damop2)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤的效果来源，必须是「三幻魔」卡的效果才能特殊召唤
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x1144)
end
-- 手牌检索效果的发动代价过滤：这张卡在手牌且未给对方观看
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 从卡组检索「三幻魔」魔法卡的过滤条件
function s.thfilter(c)
	return c:IsSetCard(0x1144) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 手牌检索效果的发动目标检测与操作信息注册（检索加入手牌与舍弃手牌）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「三幻魔」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置在效果处理时将1张卡组的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 手牌检索效果的处理：从卡组将1张「三幻魔」魔法卡加入手卡，确认后选自己1张手卡丢弃
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，指示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「三幻魔」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 让玩家从手牌中选择1张可丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			-- 将选择的手牌因效果丢弃送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 送去对方墓地的怪兽卡过滤条件
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
-- 给与对方伤害效果的发动条件：有怪兽被送去对方墓地
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 给与对方伤害效果的目标检测，设定对方玩家为目标并设置1000伤害操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定效果处理的伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设定效果处理的伤害数值为1000
	Duel.SetTargetParam(1000)
	-- 设置给与对方玩家1000点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 给与伤害效果处理：获取伤害目标与数值，对目标玩家造成伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的伤害目标玩家及伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 伤害免疫效果的发动条件：此卡被战斗或效果破坏
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 伤害免疫效果处理：注册本回合内自己受到的战斗与效果伤害变成0的永续效果
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将变更为0伤害的全局效果注册给自身玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将免疫效果伤害的全局效果注册给自身玩家
	Duel.RegisterEffect(e2,tp)
end
