--ふわんだりぃず×えんぺん
-- 效果：
-- ①：这张卡上级召唤成功的场合才能发动。从卡组把1张「随风旅鸟」魔法·陷阱卡加入手卡。那之后，可以把1只怪兽召唤。
-- ②：只要上级召唤的这张卡在怪兽区域存在，对方场上的特殊召唤的攻击表示怪兽不能把效果发动。
-- ③：这张卡和对方怪兽进行战斗的伤害计算时1次，把1张手卡除外才能发动。那只对方怪兽的攻击力·守备力直到回合结束时变成一半。
function c80611581.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合才能发动。从卡组把1张「随风旅鸟」魔法·陷阱卡加入手卡。那之后，可以把1只怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80611581,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c80611581.thcon)
	e1:SetTarget(c80611581.thtg)
	e1:SetOperation(c80611581.thop)
	c:RegisterEffect(e1)
	-- ②：只要上级召唤的这张卡在怪兽区域存在，对方场上的特殊召唤的攻击表示怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c80611581.thcon)
	e2:SetValue(c80611581.limval)
	c:RegisterEffect(e2)
	-- ③：这张卡和对方怪兽进行战斗的伤害计算时1次，把1张手卡除外才能发动。那只对方怪兽的攻击力·守备力直到回合结束时变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80611581,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(c80611581.atkcon)
	e3:SetCost(c80611581.atkcost)
	e3:SetOperation(c80611581.atkop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为上级召唤成功
function c80611581.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤卡组中「随风旅鸟」魔法·陷阱卡且能加入手牌的卡片
function c80611581.thfilter(c)
	return c:IsSetCard(0x16d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组是否存在可检索卡，并设置检索和召唤的操作信息
function c80611581.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在可检索的「随风旅鸟」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80611581.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁操作信息：进行怪兽召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 效果①的处理：将检索卡加入手牌，并可选进行一次怪兽召唤
function c80611581.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「随风旅鸟」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c80611581.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 检查玩家手牌或场上是否存在可以进行通常召唤的怪兽
		if Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,true,nil)
			-- 询问玩家是否选择进行怪兽召唤
			and Duel.SelectYesNo(tp,aux.Stringid(80611581,2)) then  --"是否把1只怪兽召唤？"
			-- 中断当前效果处理，使后续的召唤处理与检索处理不视为同时进行
			Duel.BreakEffect()
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 让玩家选择1只可以进行通常召唤的怪兽
			local sg=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,true,nil)
			if sg:GetCount()>0 then
				-- 让玩家对选择的怪兽进行通常召唤（忽略每回合通常召唤次数限制）
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 过滤不能发动效果的怪兽：处于怪兽区域、是怪兽效果、处于攻击表示且为特殊召唤
function c80611581.limval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		and rc:IsAttackPos() and rc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果③的发动条件：此卡与对方怪兽进行战斗的伤害计算时，并记录该对方怪兽
function c80611581.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if not bc then return false end
	e:SetLabelObject(bc)
	return bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- 效果③的消耗：除外1张手牌，并注册单回合伤害计算时仅能发动1次的标记
function c80611581.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=e:GetLabelObject()
	-- 在发动阶段，检查是否存在战斗对象、手牌中是否有可除外的卡，且本回合伤害计算时未发动过此效果
	if chk==0 then return bc and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) and c:GetFlagEffect(80611581)==0 end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1张作为发动Cost除外的卡片
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手牌表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	c:RegisterFlagEffect(80611581,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果③的处理：使进行战斗的对方怪兽的攻击力和守备力直到回合结束时变成一半
function c80611581.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 那只对方怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(bc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e1)
		-- 那只对方怪兽的守备力直到回合结束时变成一半。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(bc:GetDefense()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e2)
	end
end
