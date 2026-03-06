--炎帝テスタロス
-- 效果：
-- ①：这张卡上级召唤成功的场合发动。对方手卡随机选1张丢弃。丢弃的卡是怪兽卡的场合，给与对方那只怪兽的等级×100伤害。
function c26205777.initial_effect(c)
	-- 对方随机丢弃1张手牌去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26205777,0))  --"对方随机丢弃1张手牌去墓地"
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c26205777.condition)
	e1:SetTarget(c26205777.target)
	e1:SetOperation(c26205777.operation)
	c:RegisterEffect(e1)
end
-- 这张卡上级召唤成功的场合发动
function c26205777.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 设置连锁操作信息，包含丢弃手牌和造成伤害
function c26205777.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	-- 设置造成伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理函数，检索对方手牌并随机丢弃，若为怪兽卡则造成等级×100的伤害
function c26205777.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,1)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		local tc=sg:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			-- 对对方造成该怪兽等级×100的伤害
			Duel.Damage(1-tp,tc:GetLevel()*100,REASON_EFFECT)
		end
	end
end
