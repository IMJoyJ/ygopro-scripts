--覇勝星イダテン
-- 效果：
-- 5星以上的战士族怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。从卡组把1只战士族·5星怪兽加入手卡。
-- ②：1回合1次，把手卡任意数量丢弃才能发动。这张卡的攻击力上升丢弃数量×200。
-- ③：这张卡和持有这张卡的等级以下的等级的对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力只在那次伤害计算时变成0。
function c96220350.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，需要2只满足过滤条件（5星以上的战士族怪兽）的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c96220350.matfilter,2,true)
	-- ①：这张卡融合召唤成功的场合才能发动。从卡组把1只战士族·5星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96220350,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,96220350)
	e1:SetCondition(c96220350.thcon)
	e1:SetTarget(c96220350.thtg)
	e1:SetOperation(c96220350.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把手卡任意数量丢弃才能发动。这张卡的攻击力上升丢弃数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96220350,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c96220350.atkcost1)
	e2:SetOperation(c96220350.atkop1)
	c:RegisterEffect(e2)
	-- ③：这张卡和持有这张卡的等级以下的等级的对方怪兽进行战斗的伤害计算时才能发动1次。那只对方怪兽的攻击力只在那次伤害计算时变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96220350,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c96220350.atkcon)
	e3:SetCost(c96220350.atkcost)
	e3:SetOperation(c96220350.atkop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：等级5星以上且是战士族的怪兽
function c96220350.matfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_WARRIOR)
end
-- 效果①发动条件：这张卡是通过融合召唤方式特殊召唤的
function c96220350.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索卡片过滤条件：等级5星的战士族怪兽，且能加入手卡
function c96220350.thfilter(c)
	return c:IsLevel(5) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果①发动阶段：检查卡组是否存在满足条件的卡，并设置检索卡片的操作信息
function c96220350.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足条件的战士族·5星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96220350.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该连锁处理会将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①效果处理：从卡组选择1只战士族·5星怪兽加入手卡，并向对方展示
function c96220350.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的战士族·5星怪兽
	local g=Duel.SelectMatchingCard(tp,c96220350.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②发动代价：检查并丢弃手卡任意数量的卡，并将丢弃的数量记录在效果标签中
function c96220350.atkcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃任意数量（1到60张）的手卡作为发动代价，返回实际丢弃的数量
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,60,REASON_COST+REASON_DISCARD)
	e:SetLabel(ct)
end
-- 效果②效果处理：使这张卡的攻击力上升丢弃数量×200
function c96220350.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=e:GetLabel()*200
		-- 这张卡的攻击力上升丢弃数量×200。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e2:SetValue(atk)
		c:RegisterEffect(e2)
	end
end
-- 效果③发动条件：这张卡与持有这张卡等级以下的等级的对方怪兽进行战斗
function c96220350.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsLevelBelow(c:GetLevel()) and bc:IsControler(1-tp)
end
-- 效果③发动代价：检查并为这张卡注册一个单次战斗伤害计算时的标志，确保1次战斗中只能发动1次
function c96220350.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(96220350)==0 end
	c:RegisterFlagEffect(96220350,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果③效果处理：使进行战斗的对方怪兽的攻击力只在那次伤害计算时变成0
function c96220350.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力只在那次伤害计算时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(0)
		bc:RegisterEffect(e1)
	end
end
