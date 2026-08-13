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
-- 定义攻击代价的检查函数：确认是否存在可解放且不是这张卡自身的怪兽，以判断攻击宣言之际能否满足并支付必须的解放代价。
function c42035044.atcost(e,c,tp)
	-- 调用Duel.CheckReleaseGroupEx检查自己场上·手卡是否存在至少1只可解放且不是这张卡自身的怪兽（攻击宣言代价用），以决定是否满足攻击代价条件。
	return Duel.CheckReleaseGroupEx(tp,nil,1,REASON_ACTION,false,e:GetHandler())
end
-- 定义攻击代价的执行函数：在攻击宣言之际，玩家必须选择并解放这张卡以外的自己场上1只怪兽。
function c42035044.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 通过Duel.SelectReleaseGroupEx从自己场上·手卡选择1只可解放且不是这张卡自身的怪兽作为攻击代价的解放对象。
	local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_ACTION,false,e:GetHandler())
	-- 将选中的怪兽以REASON_ACTION（攻击宣言之际）解放。
	Duel.Release(g,REASON_ACTION)
end
