--くノ一ウォリアー
-- 效果：
-- 场上表侧表示存在的这张卡的控制权转移时，控制者把手卡随机丢弃1张。
function c56514812.initial_effect(c)
	-- 场上表侧表示存在的这张卡的控制权转移时，控制者把手卡随机丢弃1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56514812,0))  --"丢弃手牌"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CONTROL_CHANGED)
	e1:SetTarget(c56514812.target)
	e1:SetOperation(c56514812.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标过滤与处理，确认自身未在连锁中并设置丢弃手牌的操作信息
function c56514812.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置操作信息，表示该效果会使当前控制者（ep）丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,ep,1)
end
-- 定义效果处理，获取当前控制者的手牌并随机丢弃1张
function c56514812.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前控制者（ep）的手牌卡片组
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(ep,1)
	-- 将随机选中的手牌以效果丢弃的方式送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
