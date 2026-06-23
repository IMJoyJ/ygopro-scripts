--漆黒の豹戦士パンサーウォリアー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡的攻击宣言之际，自己必须把这张卡以外的自己场上1只怪兽解放。
function c42035044.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡的攻击宣言之际，自己必须把这张卡以外的自己场上1只怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetCost(c42035044.atcost)
	e1:SetOperation(c42035044.atop)
	c:RegisterEffect(e1)
end
-- 检查是否满足攻击宣言时的解放要求
function c42035044.atcost(e,c,tp)
	-- 检测玩家场上是否存在至少1张可解放的卡片
	return Duel.CheckReleaseGroupEx(tp,nil,1,REASON_ACTION,false,e:GetHandler())
end
-- 执行攻击宣言时的解放操作
function c42035044.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择1张满足条件的卡片进行解放
	local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_ACTION,false,e:GetHandler())
	-- 将选中的卡片从游戏中解放
	Duel.Release(g,REASON_ACTION)
end
