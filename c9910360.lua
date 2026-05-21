--ガエル・サンデス
-- 效果：
-- 「死亡青蛙」＋「死亡青蛙」＋「死亡青蛙」
-- 这只怪兽融合召唤只能使用上述的卡进行。这张卡的攻击力上升自己墓地存在的「黄泉青蛙」的数量×500的数值。
function c9910360.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以3张「死亡青蛙」为素材的融合召唤手续，且不能使用融合代替素材
	aux.AddFusionProcCodeRep(c,84451804,3,false,false)
	-- 这张卡的攻击力上升自己墓地存在的「黄泉青蛙」的数量×500的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c9910360.atkval)
	c:RegisterEffect(e2)
end
-- 定义攻击力上升值的计算函数
function c9910360.atkval(e,c)
	-- 获取自己墓地中卡名为「黄泉青蛙」的卡片数量并乘以500作为攻击力上升值
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,12538374)*500
end
