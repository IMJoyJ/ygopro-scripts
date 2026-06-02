--デーモンズ・マタドール
-- 效果：
-- 「斗牛士降临的仪式 暗之入场式」降临
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡仪式召唤的场合才能发动。从卡组把「恶魔斗牛士」以外的2张「恶魔」卡加入手卡。这个回合，这张卡不能攻击。
-- ②：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡和怪兽进行战斗的伤害计算后发动。那只怪兽破坏，给与对方1000伤害。
local s,id,o=GetID()
-- 初始化函数，注册仪式召唤限制、检索、战破抗性、战斗伤害免疫以及战后破坏并伤害的效果
function s.initial_effect(c)
	aux.AddCodeList(c,70105073)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合才能发动。从卡组把「恶魔斗牛士」以外的2张「恶魔」卡加入手卡。这个回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡和怪兽进行战斗的伤害计算后发动。那只怪兽破坏，给与对方1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 判断此卡是否是通过仪式召唤特殊召唤的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤卡组中除「恶魔斗牛士」以外的「恶魔」卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x45) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在至少2张满足条件的卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少2张「恶魔斗牛士」以外的「恶魔」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理，从卡组选择2张「恶魔」卡加入手牌，并给自身添加本回合不能攻击的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否仍存在至少2张满足条件的卡
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择2张满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
		if g:GetCount()>0 then
			-- 将选中的卡片加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 这个回合，这张卡不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断进行战斗的对方怪兽是否存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc
end
-- 破坏与伤害效果的发动准备，设置破坏对方怪兽和给予伤害的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 设置连锁的操作信息，表示该效果会破坏进行战斗的对方怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	end
	-- 设置连锁的操作信息，表示该效果会给对方造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 破坏与伤害效果的处理，破坏进行战斗的对方怪兽，并给予对方1000点伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 检查对方怪兽是否仍处于战斗关系中，并将其破坏
	if bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 then
		-- 给予对方玩家1000点效果伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
