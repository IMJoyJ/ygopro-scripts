--ガチガチガンテツ
-- 效果：
-- 2星怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升这张卡的超量素材数量×200。
-- ②：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c10002346.initial_effect(c)
	-- 添加XYZ召唤手续，使用2星怪兽作为素材进行召唤，最少需要2只，最多2只
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力上升这张卡的超量素材数量×200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(c10002346.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c10002346.reptg)
	e3:SetOperation(c10002346.repop)
	c:RegisterEffect(e3)
end
-- 返回当前卡片叠放的素材数量乘以200作为攻击力加成值
function c10002346.val(e,c)
	return e:GetHandler():GetOverlayCount()*200
end
-- 判断是否可以移除1个超量素材作为代替破坏的处理，并询问玩家是否发动此效果
function c10002346.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and not e:GetHandler():IsReason(REASON_REPLACE) end
	-- 让玩家选择是否发动此效果，若选择则继续执行后续操作
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 执行移除1个超量素材作为代替破坏的操作
function c10002346.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
