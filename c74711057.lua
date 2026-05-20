--E・HERO ジ・アース
-- 效果：
-- 「元素英雄 海洋侠」＋「元素英雄 森林侠」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：把这张卡以外的自己场上1只表侧表示的「元素英雄」怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的攻击力数值。
function c74711057.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「元素英雄 海洋侠」和「元素英雄 森林侠」为融合素材。
	aux.AddFusionProcCode2(c,37195861,75434695,true,true)
	-- ①：把这张卡以外的自己场上1只表侧表示的「元素英雄」怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74711057,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c74711057.atkcost)
	e1:SetOperation(c74711057.atkop)
	c:RegisterEffect(e1)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制这张卡只能通过融合召唤的方式特殊召唤。
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
end
c74711057.material_setcode=0x8
-- 攻击力上升效果的发动代价（Cost）函数，检查并解放自己场上1只「元素英雄」怪兽，并记录其攻击力。
function c74711057.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的1只可解放的「元素英雄」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x3008) end
	-- 玩家选择自己场上除这张卡以外的1只「元素英雄」怪兽解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x3008)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的怪兽作为发动代价解放。
	Duel.Release(g,REASON_COST)
end
-- 攻击力上升效果的实际处理（Operation）函数，使这张卡的攻击力上升被解放怪兽的攻击力数值。
function c74711057.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力直到回合结束时上升解放的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
