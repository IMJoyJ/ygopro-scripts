--メガリス・ファレグ
-- 效果：
-- 「巨石遗物」卡降临。这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「巨石遗物」仪式怪兽仪式召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升自己墓地的仪式怪兽数量×300。
function c63233638.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册一个仪式召唤效果程序，用于从手卡仪式召唤「巨石遗物」仪式怪兽，解放素材等级合计需在仪式怪兽等级以上
	local e1=aux.AddRitualProcGreater2(c,c63233638.filter,nil,nil,c63233638.matfilter,true)
	e1:SetDescription(aux.Stringid(63233638,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63233638)
	e1:SetCost(c63233638.rscost)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升自己墓地的仪式怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c63233638.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤可仪式召唤的怪兽，需为「巨石遗物」仪式怪兽，且在实际召唤处理时不能是这张卡自身
function c63233638.filter(c,e,tp,chk)
	return c:IsSetCard(0x138) and (not chk or c~=e:GetHandler())
end
-- 过滤仪式解放素材，在实际召唤处理时不能将作为效果发动者的这张卡自身解放
function c63233638.matfilter(c,e,tp,chk)
	return not chk or c~=e:GetHandler()
end
-- 仪式召唤效果的发动代价函数，用于检测并执行将这张卡从手卡丢弃的操作
function c63233638.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤仪式怪兽卡
function c63233638.cfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力与守备力上升数值的函数，数值为自己墓地的仪式怪兽数量乘以300
function c63233638.val(e,c)
	-- 计算并返回自己墓地的仪式怪兽数量乘以300的数值
	return Duel.GetMatchingGroupCount(c63233638.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*300
end
