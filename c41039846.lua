--カラスの巨群
-- 效果：
-- 这张卡不能从卡组特殊召唤。这张卡1回合只有1次可以变成里侧守备表示。这张卡反转召唤成功时，对方手卡随机丢弃1张。
function c41039846.initial_effect(c)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41039846,0))  --"变成里侧表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c41039846.target)
	e1:SetOperation(c41039846.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，对方手卡随机丢弃1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41039846,1))  --"手牌丢弃"
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c41039846.hdtg)
	e2:SetOperation(c41039846.hdop)
	c:RegisterEffect(e2)
	-- 这张卡不能从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_DECK)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
end
-- 检查是否可以将此卡变为里侧表示且本回合未使用过此效果
function c41039846.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(41039846)==0 end
	c:RegisterFlagEffect(41039846,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息为改变表示形式效果
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 将此卡变为里侧守备表示
function c41039846.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 执行将卡变为里侧守备表示的操作
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 设置连锁操作信息为对方丢弃手牌效果
function c41039846.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为对方丢弃手牌效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 随机选择对方手牌并将其送去墓地
function c41039846.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌区的所有卡片
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的卡片以丢弃和效果为原因送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
