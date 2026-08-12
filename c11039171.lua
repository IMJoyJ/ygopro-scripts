--デストーイ・シザー・ウルフ
-- 效果：
-- 「锋利小鬼·剪刀」＋「毛绒动物」怪兽1只以上
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以作出最多有作为这张卡的融合素材的怪兽数量的攻击。
function c11039171.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为30068120的怪兽和满足‘毛绒动物’融合系列条件的1只以上怪兽作为融合素材进行融合召唤
	aux.AddFusionProcCodeFunRep(c,30068120,aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),1,127,false,false)
	-- 这张卡只能通过融合召唤的方式特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该特殊召唤条件为必须使用融合召唤方式
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
	-- 当这张卡特殊召唤成功时发动的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c11039171.atkop)
	c:RegisterEffect(e3)
end
-- 攻击阶段中可以进行额外攻击的效果函数
function c11039171.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使这张卡在同1次的战斗阶段中可以作出最多有作为这张卡的融合素材的怪兽数量的攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(c:GetMaterialCount()-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
