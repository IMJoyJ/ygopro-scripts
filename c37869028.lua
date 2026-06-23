--トリプル・ヴァイパー
-- 效果：
-- 这张卡在同1次的战斗阶段中可以作3次攻击。这张卡若不把自己场上存在的1只水族怪兽解放则不能攻击宣言。
function c37869028.initial_effect(c)
	-- 这张卡在同1次的战斗阶段中可以作3次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(2)
	c:RegisterEffect(e1)
	-- 这张卡若不把自己场上存在的1只水族怪兽解放则不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetCost(c37869028.atcost)
	e2:SetOperation(c37869028.atop)
	c:RegisterEffect(e2)
end
-- 检查玩家场上是否存在至少1张水族怪兽可解放
function c37869028.atcost(e,c,tp)
	-- 检查玩家场上是否存在至少1张水族怪兽可解放
	return Duel.CheckReleaseGroupEx(tp,Card.IsRace,1,REASON_ACTION,false,nil,RACE_AQUA)
end
-- 选择并解放1张水族怪兽
function c37869028.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择1张水族怪兽作为解放对象
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsRace,1,1,REASON_ACTION,false,nil,RACE_AQUA)
	-- 解放所选的水族怪兽
	Duel.Release(g,REASON_ACTION)
end
