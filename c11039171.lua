--デストーイ・シザー・ウルフ
-- 效果：
-- 「锋利小鬼·剪刀」＋「毛绒动物」怪兽1只以上
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以作出最多有作为这张卡的融合素材的怪兽数量的攻击。
function c11039171.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号30068120（「锋利小鬼·剪刀」）1只，和满足过滤条件为「毛绒动物」字段（0xa9）的怪兽1只以上（最多127只）作为融合素材。
	aux.AddFusionProcCodeFunRep(c,30068120,aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),1,127,false,false)
	-- “这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。”此处将上述限制实现为特殊召唤条件效果（不能被无效或复制）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤条件的判定值：仅当召唤方式为融合召唤时才允许特殊召唤，即禁止通过其他方式特殊召唤。
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
	-- “①：这张卡在同1次的战斗阶段中可以作出最多有作为这张卡的融合素材的怪兽数量的攻击。”此处注册在特殊召唤成功时触发的效果，并定义后续的攻击次数赋予函数。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c11039171.atkop)
	c:RegisterEffect(e3)
end
-- 特殊召唤成功时，给这张卡赋予额外的攻击次数效果：追加攻击次数为素材数量减1，使其本回合总攻击次数等于素材怪兽数量；该效果在离场、回手、除外等重置或效果无效时重置。
function c11039171.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- “①：这张卡在同1次的战斗阶段中可以作出最多有作为这张卡的融合素材的怪兽数量的攻击。”该效果的具体实现：通过EFFECT_EXTRA_ATTACK增加额外攻击次数，数值为融合素材数量减1。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(c:GetMaterialCount()-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
