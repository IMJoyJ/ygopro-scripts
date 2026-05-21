--白の輪廻
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，把持有把自身当作调整使用效果的1只鱼族怪兽从卡组加入手卡。
-- ②：1回合1次，自己的「白斗气」怪兽攻击的伤害步骤结束时才能发动。那只攻击怪兽只再1次可以继续攻击。
-- ③：1回合1次，从自己墓地有8星以上的鱼族同调怪兽特殊召唤的场合才能发动（伤害步骤也能发动）。对方场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化效果注册，包含卡片发动时的检索效果、伤害步骤结束时追加攻击的效果，以及从墓地特殊召唤8星以上鱼族同调怪兽时破坏对方场上怪兽的效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，把持有把自身当作调整使用效果的1只鱼族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的「白斗气」怪兽攻击的伤害步骤结束时才能发动。那只攻击怪兽只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，从自己墓地有8星以上的鱼族同调怪兽特殊召唤的场合才能发动（伤害步骤也能发动）。对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中满足“持有把自身当作调整使用效果的鱼族怪兽”且可以加入手牌的卡片
function s.filter(c)
	return c:IsRace(RACE_FISH) and c:IsType(TYPE_MONSTER) and c.treat_itself_tuner and c:IsAbleToHand()
end
-- 卡片发动（效果①）的发动准备，检查卡组中是否存在符合条件的怪兽并设置检索的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的、可加入手牌的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果的处理包含从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 卡片发动（效果①）的效果处理，从卡组将1只符合条件的鱼族怪兽加入手牌并给对方确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足过滤条件的怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 效果②的发动条件，检查当前攻击怪兽是否为自己控制的「白斗气」怪兽，且该怪兽仍处于战斗中并可以进行追加攻击
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	return tc:IsControler(tp) and tc:IsSetCard(0x1a7) and tc:IsRelateToBattle()
		and tc:IsChainAttackable()
end
-- 效果②的效果处理，使攻击怪兽可以再进行1次攻击
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前攻击怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
-- 过滤从自己墓地特殊召唤的、表侧表示的8星以上鱼族同调怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
		and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FISH) and c:IsLevelAbove(8)
end
-- 效果③的发动条件，检查特殊召唤的怪兽中是否存在满足条件的从自己墓地特召的8星以上鱼族同调怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果③的发动准备，检查对方场上是否存在怪兽，并设置破坏对方场上所有怪兽的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，表示此效果的处理包含破坏对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果③的效果处理，获取并破坏对方场上的所有怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的所有怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏获取到的对方场上的所有怪兽
	Duel.Destroy(sg,REASON_EFFECT)
end
