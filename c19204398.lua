--A・O・J ライト・ゲイザー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡的攻击力上升对方墓地存在的光属性怪兽数量×200的数值。
function c19204398.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只以上调整以外的怪兽参与同调
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡的攻击力上升对方墓地存在的光属性怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19204398.val)
	c:RegisterEffect(e1)
end
-- 定义攻击力计算函数，用于计算光属性怪兽数量并乘以200
function c19204398.val(e,c)
	-- 检索对方墓地存在的光属性怪兽数量，并将其乘以200作为攻击力增加量
	return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),0,LOCATION_GRAVE,nil,ATTRIBUTE_LIGHT)*200
end
