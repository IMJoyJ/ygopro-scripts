--ペンデュラム・トレジャー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只灵摆怪兽表侧加入额外卡组。
function c26237713.initial_effect(c)
	-- ①：从卡组把1只灵摆怪兽表侧加入额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26237713+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c26237713.target)
	e1:SetOperation(c26237713.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的灵摆怪兽
function c26237713.filter(c)
	return c:IsType(TYPE_PENDULUM)
end
-- 效果处理时检查是否满足条件
function c26237713.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26237713.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为将卡送入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，选择并送入额外卡组
function c26237713.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26237713,0))  --"请选择要加入额外卡组的卡"
	-- 选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c26237713.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽送入额外卡组
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
