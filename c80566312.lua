--祝祷の聖歌
-- 效果：
-- 「龙姬神 萨菲拉」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到6以上的怪兽解放，从手卡把「龙姬神 萨菲拉」仪式召唤。
-- ②：自己场上的仪式怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c80566312.initial_effect(c)
	-- 注册仪式召唤效果，指定仪式召唤怪兽为「龙姬神 萨菲拉」，且解放怪兽的等级合计需在6以上。
	aux.AddRitualProcGreaterCode(c,56350972)
	-- ②：自己场上的仪式怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(c80566312.reptg)
	e1:SetValue(c80566312.repval)
	e1:SetOperation(c80566312.repop)
	c:RegisterEffect(e1)
end
-- 过滤条件：筛选自己场上因战斗或效果破坏的表侧表示仪式怪兽。
function c80566312.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_RITUAL)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的Target函数：检查墓地的此卡是否可除外，以及是否有符合条件的仪式怪兽将被破坏，并询问玩家是否适用代替效果。
function c80566312.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c80566312.repfilter,1,nil,tp) end
	-- 询问玩家是否适用代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的Value函数：用于判断被破坏的卡是否符合代替条件。
function c80566312.repval(e,c)
	return c80566312.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的Operation函数：执行代替破坏，将此卡除外。
function c80566312.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
