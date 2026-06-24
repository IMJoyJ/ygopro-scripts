--ガチガチガンテツ
-- 效果：
-- 2星怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升这张卡的超量素材数量×200。
-- ②：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c10002346.initial_effect(c)
	-- 为这张卡添加由2只2星怪兽进行的超量召唤手续
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升这张卡的超量素材数量×200。
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
	-- ②：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c10002346.reptg)
	e3:SetOperation(c10002346.repop)
	c:RegisterEffect(e3)
end
-- 数值函数：计算并返回此卡的超量素材数量乘以200的数值
function c10002346.val(e,c)
	return e:GetHandler():GetOverlayCount()*200
end
-- 代替效果目标：检查此卡能否去除1个超量素材来代替被效果破坏，并且此破坏事件本身不是代替破坏事件
function c10002346.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and not e:GetHandler():IsReason(REASON_REPLACE) end
	-- 让玩家选择是否发动此卡的代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替效果处理：让玩家从此卡去除1个超量素材以代替破坏
function c10002346.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
