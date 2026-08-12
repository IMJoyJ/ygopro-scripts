--妖仙獣 右鎌神柱
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，另一边的自己的灵摆区域有「妖仙兽」卡存在的场合才能发动。这张卡的灵摆刻度直到回合结束时变成11。这个效果的发动后，直到回合结束时自己不是「妖仙兽」怪兽不能特殊召唤。
-- 【怪兽效果】
-- ①：这张卡召唤成功的场合发动。这张卡变成守备表示。
-- ②：只要这张卡在怪兽区域存在，对方不能把其他的「妖仙兽」怪兽作为攻击对象。
function c91420254.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤及灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，另一边的自己的灵摆区域有「妖仙兽」卡存在的场合才能发动。这张卡的灵摆刻度直到回合结束时变成11。这个效果的发动后，直到回合结束时自己不是「妖仙兽」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91420254,0))  --"刻度变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c91420254.sccon)
	e2:SetOperation(c91420254.scop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功的场合发动。这张卡变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91420254,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c91420254.postg)
	e3:SetOperation(c91420254.posop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，对方不能把其他的「妖仙兽」怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c91420254.bttg)
	c:RegisterEffect(e4)
end
-- 灵摆效果的发动条件函数：检查另一边的灵摆区域是否存在「妖仙兽」卡
function c91420254.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方灵摆区是否存在除自身以外的「妖仙兽」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xb3)
end
-- 灵摆效果的执行函数：将自身的左右灵摆刻度直到回合结束时变成11，并注册本回合不能特殊召唤「妖仙兽」以外怪兽的限制
function c91420254.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这张卡的灵摆刻度直到回合结束时变成11
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LSCALE)
	e1:SetValue(11)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e2)
	-- 这个效果的发动后，直到回合结束时自己不是「妖仙兽」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c91420254.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非「妖仙兽」怪兽的效果注册给玩家
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制的过滤函数：非「妖仙兽」怪兽不能特殊召唤
function c91420254.splimit(e,c)
	return not c:IsSetCard(0xb3)
end
-- 召唤成功时变守备表示效果的靶向函数：检查自身是否为攻击表示，并设置改变表示形式的操作信息
function c91420254.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置改变自身表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 召唤成功时变守备表示效果的执行函数：若自身仍处于表侧攻击表示，则将其变为表侧守备表示
function c91420254.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 将自身变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 攻击限制的过滤函数：对方不能选择自身以外的表侧表示「妖仙兽」怪兽作为攻击对象
function c91420254.bttg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and c~=e:GetHandler()
end
