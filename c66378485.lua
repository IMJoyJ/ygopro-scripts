--ネオフレムベル・オリジン
-- 效果：
-- 自己场上有「新炎狱火源」以外的名字带有「炎狱」的怪兽表侧表示存在，对方墓地存在的卡是3张以下的场合，这张卡可以从手卡特殊召唤。
function c66378485.initial_effect(c)
	-- 自己场上有「新炎狱火源」以外的名字带有「炎狱」的怪兽表侧表示存在，对方墓地存在的卡是3张以下的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c66378485.spcon)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「新炎狱火源」以外的名字带有「炎狱」的怪兽
function c66378485.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2c) and not c:IsCode(66378485)
end
-- 特殊召唤规则的条件判定函数
function c66378485.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张「新炎狱火源」以外的名字带有「炎狱」的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c66378485.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
		-- 检查对方墓地的卡片数量是否在3张以下
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_GRAVE)<=3
end
