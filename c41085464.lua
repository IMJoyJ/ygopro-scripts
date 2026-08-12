--リブロマンサー・リライジング
-- 效果：
-- 「书灵师」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「书灵师」仪式怪兽仪式召唤。这个效果使用场上的「书灵师·炽火燃点侠」作仪式召唤的「书灵师·炽火爆裂侠」不会被效果破坏，不能用效果除外。
local s,id,o=GetID()
-- 注册仪式召唤程序，允许玩家解放手卡或场上的怪兽，使祭品等级合计大于或等于仪式怪兽的等级，从而从手卡仪式召唤符合条件的「书灵师」仪式怪兽
function s.initial_effect(c)
	-- 记录该卡上记载着「书灵师」系列的卡（45001322）和「书灵师·炽火燃点侠」（88106656）
	aux.AddCodeList(c,45001322,88106656)
	-- 设置仪式召唤条件为等级合计直到变成仪式召唤的怪兽的等级以上为止，从手卡进行仪式召唤，不使用墓地怪兽作为祭品，不设置额外的素材过滤条件，不暂停处理，仪式召唤成功后执行额外处理函数s.extraop
	aux.AddRitualProcGreater2(c,aux.FilterBoolFunction(Card.IsSetCard,0x17c),LOCATION_HAND,nil,nil,false,s.extraop)
end
-- 筛选满足条件的卡：卡号为45001322（书灵师）且之前位置为场上的怪兽
function s.filter(c)
	return c:IsCode(45001322) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 当仪式召唤成功且满足条件时，为仪式召唤的怪兽（tc）注册两个效果：一是使其不会被效果破坏，二是使其不能被效果除外
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not (tc and tc:IsCode(88106656) and mat:IsExists(s.filter,1,nil)) then return end
	local c=e:GetHandler()
	-- 这个效果使用场上的「书灵师·炽火燃点侠」作仪式召唤的「书灵师·炽火爆裂侠」不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"「书灵师再崛起」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(1)
	tc:RegisterEffect(e1)
	-- 这个效果使用场上的「书灵师·炽火燃点侠」作仪式召唤的「书灵师·炽火爆裂侠」不能用效果除外
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
-- 设置一个用于限制除外效果的目标函数，仅对自身生效且原因必须为效果
function s.rmlimit(e,c,tp,r,re)
	return c==e:GetHandler() and r&REASON_EFFECT>0
end
