--ペンデュラム・トレジャー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只灵摆怪兽表侧加入额外卡组。
function c26237713.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只灵摆怪兽表侧加入额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26237713+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c26237713.target)
	e1:SetOperation(c26237713.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：检查卡片是否为灵摆怪兽，用于后续从卡组中选出可加入额外卡组的灵摆怪兽。
function c26237713.filter(c)
	return c:IsType(TYPE_PENDULUM)
end
-- 效果发动时的目标检查与操作信息设置：在chk==0时确认卡组中存在可选的灵摆怪兽，并登记将卡组中的卡送去额外卡组的操作信息。
function c26237713.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中是否存在至少1只灵摆怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c26237713.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：从己方卡组选1张卡送去额外卡组，该信息用于后续连锁判定和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时实际执行：提示玩家选择卡组中的1只灵摆怪兽，将其表侧加入额外卡组。
function c26237713.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择卡片的提示信息，提示内容为“请选择要加入额外卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26237713,0))  --"请选择要加入额外卡组的卡"
	-- 从己方卡组中选择1只满足筛选条件的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c26237713.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽以表侧表示送入其持有者的额外卡组，处理原因为卡的效果。
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
