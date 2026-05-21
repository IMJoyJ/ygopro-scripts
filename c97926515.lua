--緊急救急救命レスキュー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己基本分比对方少的场合才能发动。从卡组把3只攻击力300/守备力100的兽族怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。
function c97926515.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己基本分比对方少的场合才能发动。从卡组把3只攻击力300/守备力100的兽族怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,97926515+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c97926515.condition)
	e1:SetTarget(c97926515.target)
	e1:SetOperation(c97926515.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c97926515.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己当前生命值是否低于对方生命值
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 过滤条件：卡组中攻击力300、守备力100的兽族怪兽，且能加入手卡
function c97926515.thfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAttack(300) and c:IsDefense(100) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义发动时的效果处理目标（Target）函数
function c97926515.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己卡组是否存在至少3张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97926515.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理（Operation）函数
function c97926515.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c97926515.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示自己选择要展示的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 给对方确认选出的3张怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方选择要加入自己手牌的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:Select(1-tp,1,1,nil)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方选中的那1只怪兽加入自己手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
