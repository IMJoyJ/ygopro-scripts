--BK キング・デンプシー
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组选1只4星以下的战士族·炎属性怪兽或者1张「燃烧拳」魔法·陷阱卡加入手卡或送去墓地。
-- ②：自己·对方回合可以发动。自己场上1个超量素材取除，以下效果适用。
-- ●这个回合中对方不能把自己场上的「燃烧拳击手」怪兽作为效果的对象。
function c46804536.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足条件的4星怪兽叠放，需要2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组选1只4星以下的战士族·炎属性怪兽或者1张「燃烧拳」魔法·陷阱卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46804536,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,46804536)
	e1:SetTarget(c46804536.thtg)
	e1:SetOperation(c46804536.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合可以发动。自己场上1个超量素材取除，以下效果适用。●这个回合中对方不能把自己场上的「燃烧拳击手」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46804536,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,46804537)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetTarget(c46804536.tgtg)
	e2:SetOperation(c46804536.tgop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，筛选满足条件的卡：4星以下的战士族·炎属性怪兽或「燃烧拳」魔法·陷阱卡，并且可以送去手卡或墓地
function c46804536.thfilter(c)
	return (c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
		or c:IsSetCard(0x2084) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果处理函数，检查是否满足发动条件：卡组中是否存在符合条件的卡
function c46804536.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c46804536.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果发动函数，选择并处理符合条件的卡：从卡组选择一张符合条件的卡加入手卡或送去墓地
function c46804536.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c46804536.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 判断是否将卡送入手卡：如果可以送入手卡且不能送去墓地，或者玩家选择送入手卡，则送入手卡
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将卡送入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方查看该卡
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 效果处理函数，检查是否满足发动条件：自己场上是否存在至少一个超量素材可以取除
function c46804536.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己场上是否存在至少一个超量素材可以取除
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
end
-- 效果发动函数，执行效果：取除一个超量素材并设置对方不能以「燃烧拳击手」怪兽为对象的效果
function c46804536.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功取除超量素材：如果成功取除，则继续设置效果
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)~=0 then
		-- 创建并注册一个永续效果，使对方不能以「燃烧拳击手」怪兽为对象
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 设置该效果的目标为「燃烧拳击手」怪兽
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1084))
		e1:SetValue(c46804536.tgval)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义效果值函数，返回是否为对方玩家
function c46804536.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
