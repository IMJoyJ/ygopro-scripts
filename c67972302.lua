--幸魂
-- 效果：
-- 这张卡不能特殊召唤。这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。进行手卡1只灵魂怪兽的召唤。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。
-- ③：这张卡被解放的场合，以自己墓地1只灵魂怪兽为对象发动。那只怪兽加入手卡。
function c67972302.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使该怪兽不能被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：把手卡的这张卡给对方观看才能发动。进行手卡1只灵魂怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,67972302)
	e2:SetCost(c67972302.sumcost)
	e2:SetTarget(c67972302.sumtg)
	e2:SetOperation(c67972302.sumop)
	c:RegisterEffect(e2)
	-- 使用辅助函数，为该怪兽添加在召唤·反转的回合的结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- ③：这张卡被解放的场合，以自己墓地1只灵魂怪兽为对象发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,67972303)
	e3:SetTarget(c67972302.thtg)
	e3:SetOperation(c67972302.thop)
	c:RegisterEffect(e3)
end
-- ①效果的Cost：检查手牌的这张卡是否未给对方观看（未公开状态）
function c67972302.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：筛选手牌中可以进行通常召唤的灵魂怪兽
function c67972302.sumfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsSummonable(true,nil)
end
-- ①效果的Target：检查手牌中是否存在可召唤的灵魂怪兽，并设置召唤的操作信息
function c67972302.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1只满足过滤条件的灵魂怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67972302.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果包含召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ①效果的Operation：让玩家从手牌选择1只灵魂怪兽进行通常召唤
function c67972302.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌中选择1只满足过滤条件的灵魂怪兽
	local g=Duel.SelectMatchingCard(tp,c67972302.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家对选中的怪兽进行通常召唤（忽略每回合的通常召唤次数限制）
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 过滤函数：筛选墓地中可以加入手牌的灵魂怪兽
function c67972302.thfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end
-- ③效果的Target：选择自己墓地1只灵魂怪兽作为对象，并设置加入手牌的操作信息
function c67972302.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67972302.thfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地中1只满足过滤条件的灵魂怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c67972302.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息，表示该效果包含将选中的卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果的Operation：将作为对象的墓地怪兽加入手牌
function c67972302.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
