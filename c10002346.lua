--ガチガチガンテツ
-- 效果：
-- 2星怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升这张卡的超量素材数量×200。
-- ②：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c10002346.initial_effect(c)
	-- 添加超量召唤手续：2星怪兽×2
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 只要此卡在怪兽区域存在，自己场上怪兽的攻击力上升此卡超量素材数量×200的效果
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
	-- 此卡被破坏的场合，去除1个超量素材代替破坏的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c10002346.reptg)
	e3:SetOperation(c10002346.repop)
	c:RegisterEffect(e3)
end
-- 攻击力/守备力增加值的计算函数（返回超量素材数×200）
function c10002346.val(e,c)
	return e:GetHandler():GetOverlayCount()*200
end
-- 代替破坏效果的发动条件与目标判定函数
function c10002346.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and not e:GetHandler():IsReason(REASON_REPLACE) end
	-- 询问玩家是否要使用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的执行操作函数（去除此卡的1个超量素材）
function c10002346.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
