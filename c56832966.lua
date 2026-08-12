--SNo.39 希望皇ホープ・ザ・ライトニング
-- 效果：
-- 光属性5星怪兽×3
-- 这张卡也能在自己场上的4阶「希望皇 霍普」怪兽上面重叠来超量召唤。这张卡不能作为超量召唤的素材。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时卡的效果不能发动。
-- ②：这张卡有「希望皇 霍普」怪兽在作为超量素材的场合，这张卡和对方怪兽进行战斗的伤害计算时1次，把这张卡2个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时变成5000。
function c56832966.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),5,3,c56832966.ovfilter,aux.Stringid(56832966,0))  --"是否在4阶的「希望皇 霍普」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时卡的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(c56832966.actcon)
	c:RegisterEffect(e2)
	-- ②：这张卡有「希望皇 霍普」怪兽在作为超量素材的场合，这张卡和对方怪兽进行战斗的伤害计算时1次，把这张卡2个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时变成5000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56832966,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(c56832966.atkcon)
	e3:SetCost(c56832966.atkcost)
	e3:SetOperation(c56832966.atkop)
	c:RegisterEffect(e3)
end
-- 设置该卡片的「No.」数值为39（用于判定是否为「No.」怪兽等相关辅助函数）。
aux.xyz_number[56832966]=39
-- 叠放超量召唤的过滤条件：自己场上表侧表示的4阶「希望皇 霍普」超量怪兽。
function c56832966.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ) and c:IsRank(4)
end
-- 封锁效果发动的条件：这张卡是攻击怪兽或被攻击怪兽（即进行战斗的场合）。
function c56832966.actcon(e)
	-- 判断当前进行战斗的怪兽中是否包含这张卡自身。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 攻击力变化效果的发动条件：有进行战斗的对方怪兽，且这张卡拥有「希望皇 霍普」怪兽作为超量素材。
function c56832966.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x107f)
end
-- 攻击力变化效果的消耗与限制：取除2个超量素材作为代价，且该效果在伤害计算时只能发动1次（通过注册Flag标记限制）。
function c56832966.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) and c:GetFlagEffect(56832966)==0 end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
	c:RegisterFlagEffect(56832966,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 攻击力变化效果的处理：在伤害计算时，使这张卡的攻击力变成5000。
function c56832966.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力只在那次伤害计算时变成5000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(5000)
		c:RegisterEffect(e1)
	end
end
