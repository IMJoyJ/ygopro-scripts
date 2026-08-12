--ダイナミスト・ケラトプス
-- 效果：
-- ←3 【灵摆】 3→
-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：自己场上的怪兽只有「雾动机龙·角龙」以外的「雾动机龙」怪兽的场合，这张卡可以从手卡特殊召唤。
function c37752990.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(c37752990.reptg)
	e2:SetValue(c37752990.repval)
	e2:SetOperation(c37752990.repop)
	c:RegisterEffect(e2)
	-- ①：自己场上的怪兽只有「雾动机龙·角龙」以外的「雾动机龙」怪兽的场合，这张卡可以从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c37752990.spcon)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否满足被破坏条件的「雾动机龙」怪兽
function c37752990.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd8)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件，包括目标怪兽是否满足过滤条件、该卡是否可被破坏且未被预定破坏
function c37752990.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c37752990.filter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动该代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置代替破坏效果的值，返回是否满足条件的怪兽
function c37752990.repval(e,c)
	return c37752990.filter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏操作，将该卡破坏
function c37752990.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果和代替破坏原因将该卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 过滤函数，用于判断场上是否还有其他「雾动机龙」怪兽
function c37752990.cfilter(c)
	return c:IsFacedown() or c:IsCode(37752990) or not c:IsSetCard(0xd8)
end
-- 判断是否满足特殊召唤条件，包括是否有空场、是否有其他「雾动机龙」怪兽
function c37752990.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否有至少一张怪兽卡
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)>0
		-- 检查玩家场上是否没有其他「雾动机龙」怪兽
		and not Duel.IsExistingMatchingCard(c37752990.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
