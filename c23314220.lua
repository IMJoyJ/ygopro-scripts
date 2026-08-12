--ルドラの魔導書
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：「冰火之魔导书」以外的自己的手卡·场上（表侧表示）1张「魔导书」卡或者自己场上1只表侧表示的魔法师族怪兽送去墓地，自己抽2张。
function c23314220.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23314220+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c23314220.target)
	e1:SetOperation(c23314220.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断满足条件的「魔导书」卡或魔法师族怪兽
function c23314220.filter(c)
	return (((c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(0x106e))
		or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER)))
		and not c:IsCode(23314220) and c:IsAbleToGrave()
end
-- 效果的发动条件检查，判断是否可以抽2张卡且场上存在满足条件的卡
function c23314220.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 判断场上是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c23314220.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置将要送去墓地的卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	-- 设置将要抽卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理函数，选择目标卡并执行送去墓地和抽卡效果
function c23314220.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c23314220.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	local tc=g:GetFirst()
	-- 将选中的卡送去墓地并确认已进入墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
