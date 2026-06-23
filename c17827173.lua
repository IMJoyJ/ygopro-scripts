--ふわんだりぃず×とっかん
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤成功的场合，以除外的1张自己的「随风旅鸟」卡为对象才能发动。那张卡加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
-- ②：表侧表示的这张卡从场上离开的场合除外。
-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
function c17827173.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以除外的1张自己的「随风旅鸟」卡为对象才能发动。那张卡加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17827173,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,17827173)
	e1:SetCost(c17827173.cost)
	e1:SetTarget(c17827173.thtg)
	e1:SetOperation(c17827173.thop)
	c:RegisterEffect(e1)
	-- 注册一个“表侧表示的这张卡从场上离开的场合除外”的效果
	aux.AddBanishRedirect(c)
	-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17827173,1))  --"这张卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,17827174)
	e3:SetCondition(c17827173.thcon2)
	e3:SetCost(c17827173.cost)
	e3:SetTarget(c17827173.thtg2)
	e3:SetOperation(c17827173.thop2)
	c:RegisterEffect(e3)
end
-- 支付费用：在该回合中，自己不能特殊召唤怪兽
function c17827173.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在该回合中是否已经进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个使对方不能特殊召唤怪兽的效果并注册
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：检查是否为表侧表示的「随风旅鸟」卡且能加入手卡
function c17827173.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16d) and c:IsAbleToHand()
end
-- 设置效果目标：选择1张除外的自己的「随风旅鸟」卡
function c17827173.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c17827173.thfilter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c17827173.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c17827173.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息：可以召唤1只鸟兽族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 过滤函数：检查是否为可通常召唤的鸟兽族怪兽
function c17827173.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WINDBEAST)
end
-- 效果处理：将目标卡加入手牌，然后询问是否召唤鸟兽族怪兽
function c17827173.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡有效且已加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 检查手牌或场上是否存在可通常召唤的鸟兽族怪兽
		and Duel.IsExistingMatchingCard(c17827173.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否要召唤鸟兽族怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(17827173,2)) then  --"是否把鸟兽族怪兽召唤？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 选择满足条件的1只鸟兽族怪兽作为召唤对象
		local sg=Duel.SelectMatchingCard(tp,c17827173.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 将选定的鸟兽族怪兽通常召唤
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
	end
end
-- 效果条件：确认召唤的怪兽为玩家控制且为鸟兽族
function c17827173.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsRace(RACE_WINDBEAST)
end
-- 设置效果目标：确认该卡能加入手牌
function c17827173.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息：将该卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将该卡加入手牌
function c17827173.thop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将该卡以效果原因送入手牌
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
