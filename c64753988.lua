--サイバーダーク・ワールド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以把同名卡不在自己墓地存在的1只「电子暗黑」怪兽从卡组加入手卡。
-- ②：自己主要阶段才能发动。进行1只「电子暗黑」怪兽的召唤。
-- ③：「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
function c64753988.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以把同名卡不在自己墓地存在的1只「电子暗黑」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64753988+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c64753988.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。进行1只「电子暗黑」怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64753988,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,64753989)
	e2:SetTarget(c64753988.sumtg)
	e2:SetOperation(c64753988.sumop)
	c:RegisterEffect(e2)
	-- ③：「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(64753988)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
end
-- 过滤卡组中满足“同名卡不在自己墓地存在”的「电子暗黑」怪兽
function c64753988.filter(c,tp)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查自己墓地中是否存在同名卡
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 魔法卡发动时的效果处理：可以从卡组检索1只满足条件的「电子暗黑」怪兽
function c64753988.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足检索条件的「电子暗黑」怪兽
	local g=Duel.GetMatchingGroup(c64753988.filter,tp,LOCATION_DECK,0,nil,tp)
	-- 若存在满足条件的怪兽，则询问玩家是否从卡组把「电子暗黑」怪兽加入手卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(64753988,1)) then  --"是否从卡组把「电子暗黑」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤手牌或怪兽区中可以进行通常召唤的「电子暗黑」怪兽
function c64753988.sumfilter(c)
	return c:IsSetCard(0x4093) and c:IsSummonable(true,nil)
end
-- 召唤效果的发动准备与合法性检测
function c64753988.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或怪兽区是否存在可以召唤的「电子暗黑」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64753988.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息为进行1次召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 召唤效果的处理：选择并进行1只「电子暗黑」怪兽的召唤
function c64753988.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家选择1只手牌或怪兽区中满足条件的「电子暗黑」怪兽
	local g=Duel.SelectMatchingCard(tp,c64753988.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 忽略每回合通常召唤次数限制，对选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
