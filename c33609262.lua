--帝王の深怨
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1只攻击力2400/守备力1000的怪兽或者1只攻击力2800/守备力1000的怪兽给对方观看才能发动。从卡组把「帝王的深怨」以外的1张「帝王」魔法·陷阱卡加入手卡。
function c33609262.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,33609262+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c33609262.cost)
	e1:SetTarget(c33609262.target)
	e1:SetOperation(c33609262.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查手卡中是否存在攻击力为2400或2800、守备力为1000且未公开的怪兽。
function c33609262.cfilter(c)
	return c:IsAttack(2400,2800) and c:IsDefense(1000) and not c:IsPublic()
end
-- 效果作用：发动时需要选择手卡中满足条件的1只怪兽给对方确认，并洗切手卡。
function c33609262.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否手卡中存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c33609262.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：向玩家提示选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 效果作用：选择手卡中满足条件的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,c33609262.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 效果作用：向对方玩家确认所选的怪兽。
	Duel.ConfirmCards(1-tp,g)
	-- 效果作用：将手卡洗切。
	Duel.ShuffleHand(tp)
end
-- 效果作用：检查卡组中是否存在「帝王」魔法·陷阱卡且不是「帝王的深怨」。
function c33609262.filter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(33609262) and c:IsAbleToHand()
end
-- 效果作用：发动时判断卡组中是否存在满足条件的魔法或陷阱卡。
function c33609262.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断卡组中是否存在满足条件的魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c33609262.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁操作信息，表示将从卡组检索1张「帝王」魔法·陷阱卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：发动时从卡组中选择1张「帝王」魔法·陷阱卡加入手牌，并向对方确认。
function c33609262.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：向玩家提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从卡组中选择1张满足条件的魔法或陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c33609262.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡以效果原因加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：向对方玩家确认所选的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
