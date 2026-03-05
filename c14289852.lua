--岩投げエリア
-- 效果：
-- ①：只要这张卡在场地区域存在，自己怪兽被战斗破坏的场合，可以作为代替从自己卡组把1只岩石族怪兽送去墓地。这个效果1回合只能适用1次。
function c14289852.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个场地魔法卡的永续效果，用于处理战斗破坏的代替效果
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
-- 过滤函数，用于判断目标怪兽是否为己方且因战斗破坏
function c14289852.dfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 过滤函数，用于判断卡组中是否存在可送去墓地的岩石族怪兽
function c14289852.repfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
-- 判断是否满足发动条件：己方有因战斗破坏的怪兽且卡组中有岩石族怪兽
function c14289852.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c14289852.dfilter,1,nil,tp)
		-- 检查卡组中是否存在满足条件的岩石族怪兽
		and Duel.IsExistingMatchingCard(c14289852.repfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家询问是否发动此效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 判断被破坏的怪兽是否为己方且因战斗破坏
function c14289852.value(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_BATTLE)
end
-- 选择并把符合条件的岩石族怪兽送去墓地
function c14289852.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组中选择1只岩石族怪兽
	local g=Duel.SelectMatchingCard(tp,c14289852.repfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
