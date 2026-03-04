--キッズ・ガード
-- 效果：
-- 把自己场上存在的1只「英雄小子」作为祭品。对方怪兽的攻击无效，从自己卡组把1只名字带有「元素英雄」的怪兽加入手卡。
function c10759529.initial_effect(c)
	-- 效果原文内容：把自己场上存在的1只「英雄小子」作为祭品。对方怪兽的攻击无效，从自己卡组把1只名字带有「元素英雄」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c10759529.condition)
	e1:SetCost(c10759529.cost)
	e1:SetTarget(c10759529.target)
	e1:SetOperation(c10759529.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为对方攻击时发动
function c10759529.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：当前回合玩家不是发动者时才能发动
	return tp~=Duel.GetTurnPlayer()
end
-- 效果作用：支付费用时的处理
function c10759529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在1只「英雄小子」可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,32679370) end
	-- 效果作用：选择1只「英雄小子」进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,32679370)
	-- 效果作用：将选中的怪兽解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 效果作用：检索条件过滤函数
function c10759529.filter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用：设定连锁处理的目标
function c10759529.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10759529.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁处理信息为检索怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：发动时的处理
function c10759529.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：无效对方的攻击
	Duel.NegateAttack()
	-- 效果作用：提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 效果作用：从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c10759529.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方手牌中加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
