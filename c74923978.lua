--強制接収
-- 效果：
-- 自己丢弃手卡时才能发动。那之后每次自己的手卡丢弃，对方选择相同数量的手卡丢弃。
function c74923978.initial_effect(c)
	-- 自己丢弃手卡时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DISCARD)
	e1:SetCondition(c74923978.condition)
	c:RegisterEffect(e1)
	-- 那之后每次自己的手卡丢弃，对方选择相同数量的手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74923978,0))  --"手牌丢弃"
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCondition(c74923978.condition)
	e2:SetTarget(c74923978.target)
	e2:SetOperation(c74923978.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查被丢弃的卡片原本的控制者是否为自己
function c74923978.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 发动条件：被丢弃的卡片中存在自己原本拥有的卡（即自己丢弃了手卡）
function c74923978.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74923978.cfilter,1,nil,tp)
end
-- 效果的目标处理：计算自己丢弃的手卡数量并保存，设置对方丢弃相同数量手卡的操作信息
function c74923978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=eg:FilterCount(c74923978.cfilter,nil,tp)
	e:SetLabel(ct)
	-- 设置操作信息：对方丢弃对应数量的手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,ct)
end
-- 效果的运行处理：获取保存的丢弃数量，让对方丢弃相同数量的手卡
function c74923978.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 让对方玩家因效果丢弃指定数量的手卡
	Duel.DiscardHand(1-tp,nil,ct,ct,REASON_EFFECT+REASON_DISCARD)
end
