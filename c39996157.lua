--機械天使の儀式
-- 效果：
-- 「电子化天使」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「电子化天使」仪式怪兽仪式召唤。
-- ②：自己场上的光属性怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c39996157.initial_effect(c)
	-- 注册仪式召唤程序，条件为解放手卡或场上的怪兽使等级合计达到仪式怪兽等级以上，并从手卡特殊召唤符合条件的「电子化天使」仪式怪兽
	aux.AddRitualProcGreater2(c,c39996157.ritual_filter)
	-- ②：自己场上的光属性怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c39996157.reptg)
	e2:SetValue(c39996157.repval)
	e2:SetOperation(c39996157.repop)
	c:RegisterEffect(e2)
end
-- 筛选可以被仪式召唤的「电子化天使」仪式怪兽
function c39996157.ritual_filter(c)
	return c:IsSetCard(0x2093)
end
-- 筛选自己场上被战斗或效果破坏的光属性怪兽
function c39996157.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否可以发动代替破坏效果，检查是否有满足条件的怪兽被破坏且该卡可以除外
function c39996157.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c39996157.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 设置代替破坏效果的判断条件，返回满足条件的怪兽
function c39996157.repval(e,c)
	return c39996157.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果，将该卡从墓地除外
function c39996157.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡以效果原因除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
