--キッズ・ガード
-- 效果：
-- 把自己场上存在的1只「英雄小子」作为祭品。对方怪兽的攻击无效，从自己卡组把1只名字带有「元素英雄」的怪兽加入手卡。
function c10759529.initial_effect(c)
	-- 把自己场上存在的1只「英雄小子」作为祭品。对方怪兽的攻击无效，从自己卡组把1只名字带有「元素英雄」的怪兽加入手卡。
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
-- 发动条件函数：判断当前时点是否满足发动条件，即必须为对方回合（自己不是回合玩家）时才能发动。
function c10759529.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家不是回合玩家，因此该效果只能在对方回合（我方不是回合玩家）中满足条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 代价函数：从自己场上选择并解放1只「英雄小子」（卡号32679370）作为发动代价。
function c10759529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查自己场上是否存在至少1只可作为代价解放的「英雄小子」，存在时才可发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,32679370) end
	-- 选择自己场上的1只「英雄小子」作为要解放的代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,32679370)
	-- 将选择的「英雄小子」解放，作为发动效果的COST。
	Duel.Release(g,REASON_COST)
end
-- 检索过滤器：筛选既是名字带有「元素英雄」的怪兽，又满足可以加入手卡的卡。
function c10759529.filter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的目标处理：确认卡组中存在满足条件的「元素英雄」怪兽，并设定本次效果为检索加入手牌。
function c10759529.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「元素英雄」怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c10759529.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本次效果处理时要从卡组将1张卡加入手牌（CATEGORY_TOHAND），不取对象，所以目标参数为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：无效对方怪兽的攻击，然后检索1只「元素英雄」怪兽加入手牌，并展示给对方玩家确认。
function c10759529.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前那次攻击宣言的攻击。
	Duel.NegateAttack()
	-- 给玩家显示选择卡片加入手牌的提示消息（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张满足条件的「元素英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,c10759529.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌（即自己手牌），处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
