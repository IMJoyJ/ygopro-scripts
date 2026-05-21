--リヴェンデット・ボーン
-- 效果：
-- 「复仇死者」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己墓地的不死族怪兽除外，从自己的手卡·墓地把1只「复仇死者」仪式怪兽仪式召唤。
-- ②：自己场上的「归魂复仇死者·屠魔侠」被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c94666032.initial_effect(c)
	-- 注册本卡记有「归魂复仇死者·屠魔侠」的卡片密码
	aux.AddCodeList(c,4388680)
	-- 注册仪式召唤程序，可从手卡·墓地仪式召唤，并允许将墓地的不死族怪兽除外作为解放的代替
	aux.AddRitualProcGreater2(c,c94666032.filter,LOCATION_HAND+LOCATION_GRAVE,c94666032.mfilter)
	-- 自己场上的「归魂复仇死者·屠魔侠」被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c94666032.reptg)
	e2:SetValue(c94666032.repval)
	e2:SetOperation(c94666032.repop)
	c:RegisterEffect(e2)
end
-- 过滤仪式召唤的目标怪兽，需为「复仇死者」怪兽
function c94666032.filter(c)
	return c:IsSetCard(0x106)
end
-- 过滤可作为解放代替而从墓地除外的素材怪兽，需为不死族怪兽
function c94666032.mfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 过滤需要代替破坏的怪兽，需为自己场上表侧表示且因战斗或效果破坏的「归魂复仇死者·屠魔侠」
function c94666032.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsCode(4388680)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的靶向与条件检查，确认墓地的此卡可除外且有符合条件的怪兽将被破坏，并询问玩家是否适用
function c94666032.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c94666032.repfilter,1,nil,tp) end
	-- 询问玩家是否适用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的价值函数，用于判定被破坏的怪兽是否符合代替条件
function c94666032.repval(e,c)
	return c94666032.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行函数，将墓地的这张卡除外
function c94666032.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
