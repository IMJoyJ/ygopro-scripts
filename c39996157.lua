--機械天使の儀式
-- 效果：
-- 「电子化天使」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「电子化天使」仪式怪兽仪式召唤。
-- ②：自己场上的光属性怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c39996157.initial_effect(c)
	-- 为仪式魔法卡添加一个等级合计“大于等于”仪式怪兽等级的仪式召唤效果，素材为手卡·场上的怪兽，仪式召唤从手卡进行的「电子化天使」仪式怪兽，过滤条件为卡名含有0x2093系列的怪兽。
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
-- 定义仪式怪兽的过滤函数：该怪兽必须属于「电子化天使」系列（0x2093），用于限定仪式召唤的怪兽种类。
function c39996157.ritual_filter(c)
	return c:IsSetCard(0x2093)
end
-- 定义可以被代替破坏的怪兽的筛选条件：被破坏的怪兽必须是自己场上的表侧表示光属性怪兽，位于怪兽区域，且破坏原因包含战斗或效果，并且不能是已经被代替破坏的场合。
function c39996157.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标判定：在效果发动判定时，确认墓地中的此卡可以被除外，并且本次破坏的怪兽中存在满足代替条件的怪兽，以此作为能否发动的条件。
function c39996157.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c39996157.repfilter,1,nil,tp) end
	-- 弹出是否发动代替破坏效果的询问，让当前玩家选择是否将此卡从墓地除外来代替破坏。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的Value计算函数：对每个将要被破坏的怪兽调用repfilter进行判断，确认该怪兽是否适用于此代替破坏效果。
function c39996157.repval(e,c)
	return c39996157.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果发动后的处理操作：将墓地中的此卡除外，以代替原本的破坏。
function c39996157.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地以表侧表示除外，作为代替破坏的执行动作，处理原破坏将被抵消。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
