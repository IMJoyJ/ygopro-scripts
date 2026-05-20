--地天の騎士ガイアドレイク
-- 效果：
-- 「大地之骑士 盖亚骑士」＋效果怪兽以外的同调怪兽
-- ①：只要这张卡在怪兽区域存在，这张卡不会被怪兽的效果破坏，双方不能把这张卡作为怪兽的效果的对象。
function c58601383.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，素材为「大地之骑士 盖亚骑士」＋效果怪兽以外的同调怪兽
	aux.AddFusionProcCodeFun(c,97204936,c58601383.ffilter,1,true,true)
	-- ①：只要这张卡在怪兽区域存在，...双方不能把这张卡作为怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c58601383.efilter1)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，这张卡不会被怪兽的效果破坏...
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c58601383.efilter2)
	c:RegisterEffect(e3)
end
c58601383.material_type=TYPE_SYNCHRO
-- 过滤融合素材：必须是同调怪兽且不能是效果怪兽
function c58601383.ffilter(c)
	return c:IsFusionType(TYPE_SYNCHRO) and not c:IsFusionType(TYPE_EFFECT)
end
-- 过滤效果对象免疫的来源：必须是怪兽的效果
function c58601383.efilter1(e,re,rp)
	return re:IsActiveType(TYPE_EFFECT)
end
-- 过滤效果破坏免疫的来源：必须是怪兽的效果
function c58601383.efilter2(e,re)
	return re:IsActiveType(TYPE_EFFECT)
end
