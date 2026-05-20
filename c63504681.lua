--No.86 H－C ロンゴミアント
-- 效果：
-- 战士族4星怪兽×2只以上（最多5只）
-- ①：对方结束阶段发动。这张卡1个超量素材取除。
-- ②：这张卡的超量素材数量让这张卡得到以下效果。
-- ●1个以上：这张卡不会被战斗破坏。
-- ●2个以上：这张卡的攻击力·守备力上升1500。
-- ●3个以上：这张卡不受其他卡的效果影响。
-- ●4个以上：对方不能把怪兽召唤·特殊召唤。
-- ●5个以上：1回合1次，可以发动。对方场上的卡全部破坏。
function c63504681.initial_effect(c)
	-- 添加XYZ召唤手续：战士族4星怪兽2只以上（最多5只）
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2,nil,nil,5)
	c:EnableReviveLimit()
	-- ①：对方结束阶段发动。这张卡1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63504681,0))  --"取除素材"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c63504681.rmcon)
	e1:SetOperation(c63504681.rmop)
	c:RegisterEffect(e1)
	-- ●1个以上：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(c63504681.effcon)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	-- ●2个以上：这张卡的攻击力·守备力上升1500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1500)
	e3:SetCondition(c63504681.effcon)
	e3:SetLabel(2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ●3个以上：这张卡不受其他卡的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(c63504681.efilter)
	e5:SetCondition(c63504681.effcon)
	e5:SetLabel(3)
	c:RegisterEffect(e5)
	-- ●4个以上：对方不能把怪兽召唤·特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(0,1)
	e6:SetCondition(c63504681.effcon)
	e6:SetLabel(4)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e7)
	-- ●5个以上：1回合1次，可以发动。对方场上的卡全部破坏。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(63504681,1))  --"全部破坏"
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetCountLimit(1)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(c63504681.effcon)
	e8:SetTarget(c63504681.destg)
	e8:SetOperation(c63504681.desop)
	e8:SetLabel(5)
	c:RegisterEffect(e8)
end
-- 设置该怪兽的“No.”编号为86
aux.xyz_number[63504681]=86
-- 定义对方结束阶段取除超量素材效果的发动条件
function c63504681.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 定义对方结束阶段取除超量素材效果的具体操作
function c63504681.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
-- 根据超量素材数量判断是否满足获得对应效果的条件
function c63504681.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>=e:GetLabel()
end
-- 过滤不受影响的效果，判定是否为其他卡的效果
function c63504681.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 定义对方场上卡片全部破坏效果的发动准备与合法性检查
function c63504681.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方场上是否存在至少1张卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息为破坏对方场上的所有卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义对方场上卡片全部破坏效果的具体操作
function c63504681.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏获取到的对方场上的所有卡片
	Duel.Destroy(g,REASON_EFFECT)
end
