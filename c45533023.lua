--RR－ブレイズ・ファルコン
-- 效果：
-- 鸟兽族5星怪兽×3
-- ①：持有超量素材的这张卡可以直接攻击。
-- ②：这张卡给与对方战斗伤害时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的特殊召唤的怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
function c45533023.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足鸟兽族条件的5星怪兽3只作为素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),5,3)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c45533023.dacon)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45533023,0))  --"1只怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c45533023.descon)
	e2:SetTarget(c45533023.destg1)
	e2:SetOperation(c45533023.desop1)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的特殊召唤的怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45533023,1))  --"特殊召唤的怪兽全部破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c45533023.descost)
	e3:SetTarget(c45533023.destg2)
	e3:SetOperation(c45533023.desop2)
	c:RegisterEffect(e3)
end
-- 效果条件：持有超量素材时才能发动
function c45533023.dacon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 效果条件：造成战斗伤害时且为对方伤害才能发动
function c45533023.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置效果目标：选择对方场上1只怪兽作为破坏对象
function c45533023.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息：将破坏的怪兽数量设为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏目标怪兽
function c45533023.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 支付效果代价：从自身取除1个超量素材
function c45533023.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：判断怪兽是否为特殊召唤
function c45533023.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置效果目标：检查对方场上是否存在特殊召唤的怪兽
function c45533023.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的特殊召唤怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45533023.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c45533023.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果操作信息：将要破坏的怪兽数量设为实际数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置效果操作信息：给与对方破坏怪兽数量×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 效果处理：破坏所有特殊召唤怪兽并造成伤害
function c45533023.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有特殊召唤的怪兽
	local sg=Duel.GetMatchingGroup(c45533023.filter,tp,0,LOCATION_MZONE,nil)
	-- 将所有特殊召唤怪兽破坏
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 then
		-- 给与对方破坏怪兽数量×500的伤害
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
