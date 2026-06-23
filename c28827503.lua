--Into the VRAINS！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材作连接召唤。那次连接召唤不会被无效化，在那次连接召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：这张卡在墓地存在的状态，自己场上的连接怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己墓地选原本种族和那只怪兽相同的1只怪兽加入手卡。
function c28827503.initial_effect(c)
	-- ①：从手卡把1只怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材作连接召唤。那次连接召唤不会被无效化，在那次连接召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28827503,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28827503+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28827503.target)
	e1:SetOperation(c28827503.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的连接怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己墓地选原本种族和那只怪兽相同的1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28827503,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c28827503.thcon)
	e2:SetTarget(c28827503.thtg)
	e2:SetOperation(c28827503.thop)
	c:RegisterEffect(e2)
end
-- 连接召唤的过滤函数，用于判断是否可以连接召唤
function c28827503.lkfilter(c,mc)
	return c:IsLinkSummonable(nil,mc)
end
-- 特殊召唤的过滤函数，用于判断是否可以特殊召唤
function c28827503.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在可以连接召唤的额外怪兽
		and Duel.IsExistingMatchingCard(c28827503.lkfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- 判断是否满足特殊召唤的条件
function c28827503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以特殊召唤2次
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家场上是否有足够的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c28827503.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果处理函数，执行特殊召唤和连接召唤
function c28827503.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c28827503.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试特殊召唤怪兽
	if not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
		return
	end
	local c=e:GetHandler()
	-- 使特殊召唤的怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
	-- 刷新场上信息
	Duel.AdjustAll()
	if not tc:IsLocation(LOCATION_MZONE) then return end
	-- 获取可以连接召唤的额外怪兽
	local tg=Duel.GetMatchingGroup(c28827503.lkfilter,tp,LOCATION_EXTRA,0,nil,tc)
	if tg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 设置连接召唤前的处理效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BE_PRE_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
		e3:SetCondition(c28827503.effcon)
		e3:SetOperation(c28827503.effop2)
		tc:RegisterEffect(e3,true)
		-- 设置连接召唤后的处理效果
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_BE_MATERIAL)
		e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
		e4:SetCondition(c28827503.effcon)
		e4:SetOperation(c28827503.effop1)
		tc:RegisterEffect(e4,true)
		-- 执行连接召唤
		Duel.LinkSummon(tp,sc,nil,tc)
	end
end
-- 判断连接召唤的触发条件
function c28827503.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
-- 设置连接召唤成功后的处理效果
function c28827503.effop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 设置连接召唤成功后的连锁限制
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetOperation(c28827503.sumop)
	rc:RegisterEffect(e1,true)
	e:Reset()
end
-- 设置连锁限制
function c28827503.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制直到连锁结束
	Duel.SetChainLimitTillChainEnd(c28827503.chainlm)
end
-- 连锁限制的判断函数
function c28827503.chainlm(e,rp,tp)
	return tp==rp
end
-- 设置连接召唤的怪兽不能被无效特殊召唤
function c28827503.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 设置连接召唤的怪兽不能被无效特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	e:Reset()
end
-- 判断被破坏的怪兽是否为连接怪兽
function c28827503.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_LINK)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 判断是否满足效果发动条件
function c28827503.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28827503.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 判断墓地中的怪兽是否满足种族条件
function c28827503.thfilter(c,race)
	return c:GetOriginalRace()&race>0 and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示要将怪兽加入手牌
function c28827503.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c28827503.cfilter,nil,tp)
		local race=0
		local tc=g:GetFirst()
		while tc do
			race=bit.bor(race,tc:GetOriginalRace())
			tc=g:GetNext()
		end
		e:SetLabel(race)
		-- 检查是否存在满足种族条件的怪兽
		return Duel.IsExistingMatchingCard(c28827503.thfilter,tp,LOCATION_GRAVE,0,1,nil,race)
	end
	-- 设置连锁操作信息，表示要将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，执行将怪兽加入手牌
function c28827503.thop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28827503.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,race)
	if g:GetCount()>0 then
		-- 将怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
