--XX－セイバー ガトムズ
-- 效果：
-- 调整＋地属性怪兽1只以上
-- ①：把自己场上1只「X-剑士」怪兽解放才能发动。对方手卡随机1张丢弃。
function c52352005.initial_effect(c)
	-- 添加同调召唤手续：调整+地属性怪兽1只以上
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	c:EnableReviveLimit()
	-- ①：把自己场上1只「X-剑士」怪兽解放才能发动。对方手卡随机1张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52352005,0))
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c52352005.cost)
	e1:SetTarget(c52352005.target)
	e1:SetOperation(c52352005.operation)
	c:RegisterEffect(e1)
	-- 调整＋地属性怪兽1只以上
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c52352005.valcheck)
	c:RegisterEffect(e2)
end
-- 同调素材检查：若使用了2只以上的调整怪兽，则为自身注册特定的标记效果（以允许使用多只调整进行同调召唤）
function c52352005.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整＋地属性怪兽1只以上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果①的Cost阶段：检查并选择场上1只「X-剑士」怪兽解放
function c52352005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以解放的「X-剑士」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x100d) end
	-- 玩家选择场上1只「X-剑士」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x100d)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果①的Target阶段：检查对方手卡数量并设置丢弃手卡的操作信息
function c52352005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果①的Operation阶段：随机选择对方1张手卡送去墓地
function c52352005.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的全部手卡
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选中的手卡以效果丢弃的方式送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
