--ローズ・ウィッチ
-- 效果：
-- 植物族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c23087070.initial_effect(c)
	-- 植物族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c23087070.condition)
	c:RegisterEffect(e1)
end
-- 判定上级召唤的怪兽是否为植物族，若为植物族则允许本卡作为2只祭品解放。
function c23087070.condition(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_PLANT) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
