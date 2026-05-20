--デスサイズ・キラー
-- 效果：
-- ①：把这张卡以外的自己场上1只昆虫族怪兽解放才能发动。这张卡的攻击力直到回合结束时上升500。
function c66973070.initial_effect(c)
	-- ①：把这张卡以外的自己场上1只昆虫族怪兽解放才能发动。这张卡的攻击力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66973070,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c66973070.atkcost)
	e1:SetOperation(c66973070.operation)
	c:RegisterEffect(e1)
end
-- 检查并执行发动代价：解放这张卡以外的自己场上1只昆虫族怪兽
function c66973070.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的、可解放的昆虫族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_INSECT) end
	-- 玩家选择自己场上除这张卡以外的1只昆虫族怪兽
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,e:GetHandler(),RACE_INSECT)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 效果处理：若此卡表侧表示存在且与效果有联系，则直到回合结束时其攻击力上升500
function c66973070.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
