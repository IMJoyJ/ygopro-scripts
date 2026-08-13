--真紅眼の凶星竜－メテオ・ドラゴン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●只要这张卡在怪兽区域存在，这张卡以外的自己场上的「真红眼」怪兽不会被战斗·效果破坏。
function c17871506.initial_effect(c)
	-- 给这张卡赋予二重怪兽属性，使其在场上·墓地当作通常怪兽使用，并可进行再度召唤。
	aux.EnableDualAttribute(c)
	-- ●只要这张卡在怪兽区域存在，这张卡以外的自己场上的「真红眼」怪兽不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c17871506.indtg)
	e1:SetValue(1)
	-- 设置该效果仅在二重怪兽处于再度召唤状态（视为效果怪兽）时才适用，即这张卡通过②的效果再度召唤后才能获得此保护效果。
	e1:SetCondition(aux.IsDualState)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end
-- 保护对象判定：具有「真红眼」字段且不是效果持有者自身，即“这张卡以外的自己场上的「真红眼」怪兽”。
function c17871506.indtg(e,c)
	return c:IsSetCard(0x3b) and c~=e:GetHandler()
end
