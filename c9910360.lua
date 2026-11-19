--ガエル・サンデス
-- 效果：
-- 「死亡青蛙」＋「死亡青蛙」＋「死亡青蛙」
-- 这只怪兽融合召唤只能使用上述的卡进行。这张卡的攻击力上升自己墓地存在的「黄泉青蛙」的数量×500的数值。
function c9910360.initial_effect(c)
	-- 记录该卡效果文上记载了「黄泉青蛙」的卡名
	aux.AddCodeList(c,12538374)
	c:EnableReviveLimit()
	-- 定义融合召唤手续：必须使用3只「死亡青蛙」作为融合素材，且不允许使用融合替代素材或简易融合等非正规方式替代
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
-- 攻击力增益计算函数：统计这张卡控制者墓地中「黄泉青蛙」的数量，并计算其乘以500的攻击力上升值
function c9910360.atkval(e,c)
	-- 获取控制者墓地中「黄泉青蛙」的张数并乘以500作为攻击力增加量
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,12538374)*500
end
