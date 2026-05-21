--ネオフレムベル・サーベル
-- 效果：
-- 对方墓地存在的卡是4张以下的场合，这张卡的攻击力上升600。对方墓地存在的卡是8张以上的场合，这张卡的攻击力下降300。
function c91554542.initial_effect(c)
	-- 对方墓地存在的卡是4张以下的场合，这张卡的攻击力上升600。对方墓地存在的卡是8张以上的场合，这张卡的攻击力下降300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c91554542.val)
	c:RegisterEffect(e1)
end
-- 根据对方墓地的卡片数量计算攻击力增减值：4张以下时上升600，8张以上时下降300，其他情况不增减
function c91554542.val(e)
	-- 获取对方墓地的卡片数量
	local gct=Duel.GetFieldGroupCount(e:GetHandler():GetControler(),0,LOCATION_GRAVE)
	if gct<=4 then return 600
	elseif gct>=8 then return -300
	else return 0 end
end
