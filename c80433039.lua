--ふわんだりぃず×すとりー
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤成功的场合，以自己或者对方的墓地1张卡为对象才能发动。那张卡除外。那之后，可以把1只鸟兽族怪兽召唤。
-- ②：表侧表示的这张卡从场上离开的场合除外。
-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
function c80433039.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以自己或者对方的墓地1张卡为对象才能发动。那张卡除外。那之后，可以把1只鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80433039,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,80433039)
	e1:SetCost(c80433039.cost)
	e1:SetTarget(c80433039.rmtg)
	e1:SetOperation(c80433039.rmop)
	c:RegisterEffect(e1)
	-- 为这张卡注册“表侧表示从场上离开的场合除外”的离场重定向效果。
	aux.AddBanishRedirect(c)
	-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80433039,1))  --"这张卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,80433040)
	e3:SetCondition(c80433039.thcon)
	e3:SetCost(c80433039.cost)
	e3:SetTarget(c80433039.thtg)
	e3:SetOperation(c80433039.thop)
	c:RegisterEffect(e3)
end
-- 效果发动的Cost函数：检查本回合是否进行过特殊召唤，并注册本回合不能特殊召唤的限制。
function c80433039.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否进行过特殊召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。①：这张卡召唤成功的场合，以自己或者对方的墓地1张卡为对象才能发动。那张卡除外。那之后，可以把1只鸟兽族怪兽召唤。③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 在全局注册“不能特殊召唤”的玩家限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 效果①的Target（发动准备）函数：确认墓地有可除外的卡，并进行取对象和设置操作信息。
function c80433039.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查双方墓地是否存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择双方墓地1张可以除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的操作信息为“除外选中的卡”。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置当前连锁的操作信息包含“通常召唤”。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 过滤函数：检索手卡或场上可以进行通常召唤的鸟兽族怪兽。
function c80433039.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WINDBEAST)
end
-- 效果①的Operation（效果处理）函数：除外目标卡片，并可以接着召唤1只鸟兽族怪兽。
function c80433039.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的除外对象。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关，则将其除外，并确认其已被成功除外。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED)
		-- 检查自己手卡或场上是否存在可以进行通常召唤的鸟兽族怪兽。
		and Duel.IsExistingMatchingCard(c80433039.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否选择进行鸟兽族怪兽的通常召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(80433039,2)) then  --"是否把鸟兽族怪兽召唤？"
		-- 中断当前效果处理，使后续的召唤处理与除外处理不视为同时进行。
		Duel.BreakEffect()
		-- 洗切玩家的手卡。
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 让玩家选择1只手卡或场上满足召唤条件的鸟兽族怪兽。
		local sg=Duel.SelectMatchingCard(tp,c80433039.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 让玩家对选择的鸟兽族怪兽进行通常召唤（忽略每回合通常召唤次数限制）。
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
	end
end
-- 效果③的Condition（发动条件）函数：检查自己场上是否有鸟兽族怪兽召唤成功。
function c80433039.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsRace(RACE_WINDBEAST)
end
-- 效果③的Target（发动准备）函数：检查自身是否能加入手卡，并设置操作信息。
function c80433039.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置当前连锁的操作信息为“将自身加入手卡”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的Operation（效果处理）函数：将除外状态的自身加入手卡。
function c80433039.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡加入持有者的手卡。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
