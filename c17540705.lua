--EMダグ・ダガーマン
-- 效果：
-- ←2 【灵摆】 2→
-- 「娱乐伙伴 奇人飞剑手」的灵摆效果1回合只能使用1次。
-- ①：这张卡发动的回合的自己主要阶段以自己墓地1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽加入手卡。
-- 【怪兽效果】
-- 「娱乐伙伴 奇人飞剑手」的怪兽效果1回合只能使用1次。
-- ①：这张卡灵摆召唤成功的回合的自己主要阶段从手卡把1只「娱乐伙伴」怪兽送去墓地才能发动。自己从卡组抽1张。
function c17540705.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：这张卡发动的回合的自己主要阶段以自己墓地1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c17540705.threg)
	c:RegisterEffect(e1)
	-- ①：这张卡灵摆召唤成功的回合的自己主要阶段从手卡把1只「娱乐伙伴」怪兽送去墓地才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17540705,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,17540705)
	e2:SetCondition(c17540705.thcon)
	e2:SetTarget(c17540705.thtg)
	e2:SetOperation(c17540705.thop)
	c:RegisterEffect(e2)
	-- 「娱乐伙伴 奇人飞剑手」的灵摆效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c17540705.regcon)
	e3:SetOperation(c17540705.drreg)
	c:RegisterEffect(e3)
	-- 「娱乐伙伴 奇人飞剑手」的怪兽效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17540705,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,17540706)
	e4:SetCondition(c17540705.drcon)
	e4:SetCost(c17540705.drcost)
	e4:SetTarget(c17540705.drtg)
	e4:SetOperation(c17540705.drop)
	c:RegisterEffect(e4)
end
-- 注册flag 17540705，用于标记灵摆效果已使用
function c17540705.threg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(17540705,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 检查是否已使用过灵摆效果
function c17540705.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17540705)~=0
end
-- 过滤墓地中的「娱乐伙伴」怪兽，满足加入手牌的条件
function c17540705.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置选择目标：从自己墓地选择1只「娱乐伙伴」怪兽
function c17540705.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c17540705.thfilter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c17540705.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c17540705.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果：将目标卡加入手牌
function c17540705.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 检查是否为灵摆召唤
function c17540705.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 注册flag 17540706，用于标记怪兽效果已使用
function c17540705.drreg(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17540706,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查是否已使用过怪兽效果
function c17540705.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17540706)~=0
end
-- 过滤手牌中的「娱乐伙伴」怪兽，满足送去墓地的条件
function c17540705.cfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 设置效果成本：丢弃1张手牌中的「娱乐伙伴」怪兽
function c17540705.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c17540705.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手牌中的「娱乐伙伴」怪兽
	Duel.DiscardHand(tp,c17540705.cfilter,1,1,REASON_COST)
end
-- 设置效果目标：自己抽1张卡
function c17540705.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作目标参数
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果：自己抽1张卡
function c17540705.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
