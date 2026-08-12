--次元の裂け目
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，被送去墓地的怪兽不去墓地而除外。
function c81674782.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，被送去墓地的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	-- 设置重定向效果的过滤函数，用于筛选原本是怪兽且当前不作为超量素材或魔陷使用的卡片
	e2:SetTarget(aux.DimensionalFissureTarget)
	e2:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，被送去墓地的怪兽不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(81674782)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(0xff,0xff)
	e3:SetTarget(c81674782.checktg)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断卡片是否处于非公开状态
function c81674782.checktg(e,c)
	return not c:IsPublic()
end
