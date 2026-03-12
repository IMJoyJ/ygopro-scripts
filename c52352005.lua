--XX－セイバー ガトムズ
-- 效果：
-- 调整＋地属性怪兽1只以上
-- ①：把自己场上1只「X-剑士」怪兽解放才能发动。对方手卡随机1张丢弃。
function c52352005.initial_effect(c)
	-- 添加同调召唤手续，要求满足调整或地属性条件的怪兽作为素材
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	c:EnableReviveLimit()
	-- ①：把自己场上1只「X-剑士」怪兽解放才能发动。对方手卡随机1张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52352005,0))  --"对方随机丢弃1张手卡"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c52352005.cost)
	e1:SetTarget(c52352005.target)
	e1:SetOperation(c52352005.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c52352005.valcheck)
	c:RegisterEffect(e2)
end
-- 检查同调召唤时是否使用了至少2只调整作为素材，若是则赋予特定效果
function c52352005.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 效果原文内容
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 支付效果代价，解放场上1只「X-剑士」怪兽
function c52352005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x100d) end
	-- 选择1只「X-剑士」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x100d)
	-- 实际执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置效果处理目标，确定对方手牌丢弃数量
function c52352005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌是否存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置连锁操作信息，指定对方随机丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 执行效果，对方随机丢弃1张手牌
function c52352005.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有手牌
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的手牌送去墓地并标记为丢弃效果
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
