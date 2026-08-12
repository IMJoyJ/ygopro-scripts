--トーテム・ファイブ
-- 效果：
-- ①：包含这张卡的5只怪兽同时特殊召唤成功的场合发动。对方场上的卡全部破坏，给与对方破坏数量×500伤害。
function c56346071.initial_effect(c)
	-- ①：包含这张卡的5只怪兽同时特殊召唤成功的场合发动。对方场上的卡全部破坏，给与对方破坏数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c56346071.descon)
	e1:SetTarget(c56346071.destg)
	e1:SetOperation(c56346071.desop)
	c:RegisterEffect(e1)
end
-- 检查同时特殊召唤的怪兽数量是否为5只，且其中包含这张卡本身
function c56346071.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==5 and eg:IsContains(e:GetHandler())
end
-- 效果发动的目标确认，获取对方场上的所有卡并设置破坏与伤害的操作信息
function c56346071.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏的操作信息，对象为对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害的操作信息，数值为对方场上卡片数量×500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 效果处理，破坏对方场上的所有卡，并根据实际破坏的数量给与对方对应的伤害
function c56346071.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏对方场上的所有卡
	Duel.Destroy(g,REASON_EFFECT)
	-- 获取本次操作中实际被破坏的卡片组
	local sg=Duel.GetOperatedGroup()
	if sg:GetCount()>0 then
		-- 给与对方实际破坏数量×500的伤害
		Duel.Damage(1-tp,sg:GetCount()*500,REASON_EFFECT)
	end
end
