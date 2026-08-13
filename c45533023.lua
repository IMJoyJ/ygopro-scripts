--RR－ブレイズ・ファルコン
-- 效果：
-- 鸟兽族5星怪兽×3
-- ①：持有超量素材的这张卡可以直接攻击。
-- ②：这张卡给与对方战斗伤害时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的特殊召唤的怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
function c45533023.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：要求素材为鸟兽族5星怪兽3只。
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
-- 直接攻击效果的发动条件：判定这张卡是否持有超量素材（叠放数大于0）。
function c45533023.dacon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- ②效果的发动条件：判定造成战斗伤害的玩家是对方，即只有给与对方战斗伤害时才满足。
function c45533023.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ②效果的目标选择与操作信息设定：选择对方场上1只怪兽作为对象，并设置破坏该怪兽的操作信息。
function c45533023.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动合法性检查：确认对方场上存在至少1只可以成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次处理将破坏1只对象怪兽（破坏分类）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取回效果对象，若该对象仍与效果关联则将其破坏。
function c45533023.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取回效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果的发动代价：确认可以取除这张卡的1个超量素材，并实际取除1个超量素材。
function c45533023.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：判断怪兽是否是以特殊召唤方式召唤的怪兽。
function c45533023.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ③效果的目标选择与操作信息设定：确认对方场上有特殊召唤的怪兽，获取所有此类怪兽，并设置破坏及伤害的操作信息。
function c45533023.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上存在至少1只特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45533023.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有特殊召唤的怪兽组。
	local g=Duel.GetMatchingGroup(c45533023.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次处理将破坏对方场上所有特殊召唤的怪兽，数量为这些怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：本次处理将给与对方伤害，伤害值为特殊召唤怪兽数量×500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- ③效果处理：获取对方场上所有特殊召唤的怪兽并全部破坏，然后根据实际破坏数量给与对方伤害。
function c45533023.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有特殊召唤的怪兽组。
	local sg=Duel.GetMatchingGroup(c45533023.filter,tp,0,LOCATION_MZONE,nil)
	-- 破坏这些怪兽，并返回实际被破坏的数量。
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 then
		-- 给与对方实际破坏数量×500的伤害。
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
