--岩投げエリア
-- 效果：
-- ①：只要这张卡在场地区域存在，自己怪兽被战斗破坏的场合，可以作为代替从自己卡组把1只岩石族怪兽送去墓地。这个效果1回合只能适用1次。
function c14289852.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
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
-- 筛选出因战斗被破坏且控制者为当前玩家（自己）的怪兽，用于判断是否有满足条件的己方怪兽被战破。
function c14289852.dfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 筛选卡组中满足岩石族且能够送去墓地的怪兽，作为代替送去墓地的候选卡。
function c14289852.repfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
-- 代替破坏的发动条件判定：存在自己控制的被战斗破坏的怪兽，同时卡组中存在可以送去墓地的岩石族怪兽。
function c14289852.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c14289852.dfilter,1,nil,tp)
		-- 同时检查卡组中是否存在至少1张岩石族且可以送去墓地的怪兽。
		and Duel.IsExistingMatchingCard(c14289852.repfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 弹出是否适用代替破坏效果的询问，由当前玩家决定是否将战斗破坏代替为从卡组送墓岩石族怪兽。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的适用判定：被破坏的卡必须是效果持有者控制者（自己）的怪兽，且破坏原因为战斗破坏。
function c14289852.value(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_BATTLE)
end
-- 效果处理：选定1只卡组中的岩石族怪兽并送入墓地，以此代替原先的战斗破坏。
function c14289852.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 发起选卡提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足岩石族且可以送去墓地的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c14289852.repfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的岩石族怪兽以效果原因送入墓地，完成代替破坏的处理。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
