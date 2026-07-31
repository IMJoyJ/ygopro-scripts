--エーリアン・マーズ
-- 效果：
-- 只要这张卡在场上表侧表示存在，「火星外星人」以外的放置有A指示物的怪兽的效果无效化。
function c99532708.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，「火星外星人」以外的放置有A指示物的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTarget(c99532708.distg)
	c:RegisterEffect(e1)
end
c99532708.mentioned_counter={
	[0x100e]=true,
}
-- 检索满足条件的怪兽组，即具有A指示物且不是火星外星人的怪兽
function c99532708.distg(e,c)
	return c:GetCounter(0x100e)>0 and not c:IsCode(99532708)
end
