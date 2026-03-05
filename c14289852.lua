--岩投げエリア
-- 效果：
-- ①：只要这张卡在场地区域存在，自己怪兽被战斗破坏的场合，可以作为代替从自己卡组把1只岩石族怪兽送去墓地。这个效果1回合只能适用1次。
function c14289852.initial_effect(c)
	-- ①：只要这张卡在场地区域存在，自己怪兽被战斗破坏的场合，可以作为代替从自己卡组把1只岩石族怪兽送去墓地。这个效果1回合只能适用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己怪兽被战斗破坏的场合，可以作为代替从自己卡组把1只岩石族怪兽送去墓地。这个效果1回合只能适用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c14289852.destg)
	e2:SetValue(c14289852.value)
	e2:SetOperation(c14289852.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查是否满足条件：目标怪兽是自己控制的且被战斗破坏
function c14289852.dfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 过滤函数，检查是否满足条件：目标卡是岩石族且可以送去墓地
function c14289852.repfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并提示玩家选择是否发动
function c14289852.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c14289852.dfilter,1,nil,tp)
		-- 检查自己卡组是否存在至少1张满足条件的岩石族怪兽
		and Duel.IsExistingMatchingCard(c14289852.repfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择是否发动该效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 效果值函数，用于判断目标怪兽是否满足被战斗破坏且是自己控制的
function c14289852.value(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_BATTLE)
end
-- 效果处理函数，用于执行将符合条件的岩石族怪兽送去墓地的操作
function c14289852.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张岩石族怪兽从卡组送去墓地
	local g=Duel.SelectMatchingCard(tp,c14289852.repfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的岩石族怪兽以效果原因送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
