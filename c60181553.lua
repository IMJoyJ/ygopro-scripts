--巨星のミラ
-- 效果：
-- 1星怪兽×3
-- 场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。此外，只要这张卡在场上表侧表示存在，自己场上表侧表示存在的4星以下的怪兽不会被卡的效果破坏。
function c60181553.initial_effect(c)
	-- 为卡片添加超量召唤手续：需要3只1星怪兽作为素材
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- 场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c60181553.reptg)
	e1:SetOperation(c60181553.repop)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上表侧表示存在，自己场上表侧表示存在的4星以下的怪兽不会被卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c60181553.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤出场上表侧表示且等级在4星以下的怪兽作为效果适用对象
function c60181553.indtg(e,c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 判断是否满足代替破坏的条件：自身有可取除的超量素材，且当前不处于代替破坏状态
function c60181553.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and not e:GetHandler():IsReason(REASON_REPLACE) end
	-- 询问玩家是否使用代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 执行代替破坏，取除这张卡的1个超量素材
function c60181553.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
