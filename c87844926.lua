--ソウル・レヴィ
-- 效果：
-- ①：「灵魂召集」在自己场上只能有1张表侧表示存在。
-- ②：只要这张卡在魔法与陷阱区域存在，每次对方对怪兽的特殊召唤成功，从对方卡组上面把3张卡送去墓地。
function c87844926.initial_effect(c)
	c:SetUniqueOnField(1,0,87844926)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，每次对方对怪兽的特殊召唤成功，从对方卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c87844926.ddcon)
	e2:SetOperation(c87844926.ddop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查特殊召唤的怪兽是否由指定玩家召唤
function c87844926.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 触发条件：检查特殊召唤成功的怪兽中是否存在对方特殊召唤的怪兽
function c87844926.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87844926.cfilter,1,nil,1-tp)
end
-- 效果处理：执行从对方卡组上面把3张卡送去墓地的操作
function c87844926.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上方的3张卡因效果送去墓地
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
