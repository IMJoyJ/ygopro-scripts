--クインテット・マジシャン
-- 效果：
-- 魔法师族怪兽×5
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：魔法师族怪兽5种类作为素材让这张卡融合召唤的场合才能发动。对方场上的卡全部破坏。
-- ②：这张卡只要在怪兽区域存在，不能解放，不能作为融合素材，不会被效果破坏。
function c84433295.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为魔法师族怪兽5只
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),5,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制只能用融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：魔法师族怪兽5种类作为素材让这张卡融合召唤的场合才能发动。对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c84433295.descon)
	e2:SetTarget(c84433295.destg)
	e2:SetOperation(c84433295.desop)
	c:RegisterEffect(e2)
	-- 魔法师族怪兽5种类作为素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c84433295.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：这张卡只要在怪兽区域存在，不能解放
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e7)
end
-- 检查融合素材是否为5种不同卡名的魔法师族怪兽，满足则在效果e2上设置标记
function c84433295.valcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsRace,nil,RACE_SPELLCASTER)
	if g:GetClassCount(Card.GetCode)==5 then e:GetLabelObject():SetLabel(1) end
end
-- 破坏效果的发动条件：自身融合召唤成功且融合素材为5种不同的卡名
function c84433295.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
-- 破坏效果的发动准备：确认对方场上有卡存在，并设置破坏的操作信息
function c84433295.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 end
	-- 设置在效果处理时将破坏对方场上所有卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行：将对方场上的卡全部破坏
function c84433295.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if g:GetCount()>0 then
		-- 因效果破坏对方场上的所有卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
