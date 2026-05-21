--リブロマンサー・ファイアバースト
-- 效果：
-- 「书灵师」卡降临。
-- ①：使用场上的怪兽作仪式召唤的这张卡不会被战斗破坏，给与对方的战斗伤害变成2倍。
-- ②：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：自己或者对方的怪兽的攻击宣言时，从自己墓地把1只「书灵师」仪式怪兽除外才能发动。这张卡的攻击力上升200。
local s,id,o=GetID()
-- 注册卡片效果：初始化仪式召唤限制、素材检查、战斗破坏抗性、战斗伤害翻倍、追加攻击怪兽次数以及攻击宣言时增加攻击力的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：使用场上的怪兽作仪式召唤的这张卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- 不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.matcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 给与对方的战斗伤害变成2倍
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.matcon)
	-- 设置战斗伤害改变效果：将此卡给予对方玩家的战斗伤害变为2倍。
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	-- ②：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：自己或者对方的怪兽的攻击宣言时，从自己墓地把1只「书灵师」仪式怪兽除外才能发动。这张卡的攻击力上升200。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(s.atkcost)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
-- 素材检查：若仪式召唤的素材中存在场上的怪兽，则给这张卡注册一个带有客户端提示的标记。
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))  --"使用场上的怪兽作仪式召唤"
	end
end
-- 效果适用条件：这张卡是仪式召唤成功，且具有使用场上怪兽作为素材的标记。
function s.matcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetFlagEffect(id)>0
end
-- 过滤条件：自己墓地的一只「书灵师」仪式怪兽，且能作为发动成本除外。
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL) and c:IsSetCard(0x17c) and c:IsAbleToRemoveAsCost()
end
-- 效果发动成本：从自己墓地把1只「书灵师」仪式怪兽除外。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：自己墓地是否存在至少1只满足过滤条件的「书灵师」仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的「书灵师」仪式怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动成本。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：若此卡在场上表侧表示存在且此效果依然适用，则使此卡的攻击力上升200。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
