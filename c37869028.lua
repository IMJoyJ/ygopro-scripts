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
-- 攻击宣言代价的判定函数：检查是否有满足条件的水族怪兽可以作为解放代价，若有则允许攻击宣言。
function c37869028.atcost(e,c,tp)
	-- 检查我方是否存在至少1只水族怪兽可作为攻击宣言的解放代价，满足则返回真。
	return Duel.CheckReleaseGroupEx(tp,Card.IsRace,1,REASON_ACTION,false,nil,RACE_AQUA)
end
-- 攻击宣言代价的处理函数：执行解放1只水族怪兽的操作，完成攻击宣言所需的代价支付。
function c37869028.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择我方1只水族怪兽作为解放对象，用于支付攻击宣言代价。
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsRace,1,1,REASON_ACTION,false,nil,RACE_AQUA)
	-- 将选择的水族怪兽解放（REASON_ACTION表示该解放为攻击宣言之际产生的代价）。
	Duel.Release(g,REASON_ACTION)
end
