--リブロマンサー・リライジング
-- 效果：
-- 「书灵师」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「书灵师」仪式怪兽仪式召唤。这个效果使用场上的「书灵师·炽火燃点侠」作仪式召唤的「书灵师·炽火爆裂侠」不会被效果破坏，不能用效果除外。
local s,id,o=GetID()
-- 定义本卡的初始效果：将两张相关卡名登记到卡片信息中，并注册仪式召唤效果及其额外处理。
function s.initial_effect(c)
	-- 将卡号45001322（书灵师·炽火燃点侠）和88106656（书灵师·炽火爆裂侠）登记为这张卡记载的卡名，以便处理相关效果的联动。
	aux.AddCodeList(c,45001322,88106656)
	-- 注册仪式魔法效果：通过解放手牌·场上的怪兽（等级合计不低于对象怪兽等级），从手卡仪式召唤1只「书灵师」仪式怪兽；召唤处理完成后执行s.extraop进行额外判定与附加效果。
	aux.AddRitualProcGreater2(c,aux.FilterBoolFunction(Card.IsSetCard,0x17c),LOCATION_HAND,nil,nil,false,s.extraop)
end
-- 判定素材是否为场上使用的「书灵师·炽火燃点侠」：该素材卡号必须是45001322，且其在此次仪式召唤前位于场上（被解放前的位置是场上）。
function s.filter(c)
	return c:IsCode(45001322) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 额外处理：若仪式召唤成功的怪兽是88106656（书灵师·炽火爆裂侠），且解放素材中存在满足s.filter的场上的「书灵师·炽火燃点侠」，则为该怪兽附加‘不会被效果破坏’和‘不能因效果除外’两个保护效果。
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not (tc and tc:IsCode(88106656) and mat:IsExists(s.filter,1,nil)) then return end
	local c=e:GetHandler()
	-- 不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"「书灵师再崛起」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(1)
	tc:RegisterEffect(e1)
	-- 不能用效果除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
-- 该函数作为EFFECT_CANNOT_REMOVE的目标判定：仅当被除外的对象是获得保护的那只怪兽且除外原因是效果（REASON_EFFECT）时返回true，从而禁止其因效果被除外。
function s.rmlimit(e,c,tp,r,re)
	return c==e:GetHandler() and r&REASON_EFFECT>0
end
