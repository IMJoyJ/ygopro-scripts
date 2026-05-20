--極星天ヴァナディース
-- 效果：
-- 这张卡可以作为「极星」调整的代替而成为同调素材。把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是「极星」怪兽。
-- ①：1回合1次，把持有和这张卡的等级不同等级的1只「极星」怪兽从卡组送去墓地才能发动。这张卡的等级直到回合结束时变成和送去墓地的怪兽相同。
function c61777313.initial_effect(c)
	-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是「极星」怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTarget(c61777313.synlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把持有和这张卡的等级不同等级的1只「极星」怪兽从卡组送去墓地才能发动。这张卡的等级直到回合结束时变成和送去墓地的怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61777313,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c61777313.cost)
	e2:SetOperation(c61777313.operation)
	c:RegisterEffect(e2)
	-- 这张卡可以作为「极星」调整的代替而成为同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(61777313)
	c:RegisterEffect(e3)
end
-- 限制其他的同调素材怪兽必须全部是「极星」怪兽
function c61777313.synlimit(e,c)
	return c:IsSetCard(0x42)
end
-- 过滤卡组中与自身等级不同、等级在1以上且能送去墓地的「极星」怪兽
function c61777313.cfilter(c,lv)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 效果①的代价：从卡组将1只等级不同的「极星」怪兽送去墓地，并记录其等级
function c61777313.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只与自身等级不同的「极星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61777313.cfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetLevel()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只与自身等级不同的「极星」怪兽
	local g=Duel.SelectMatchingCard(tp,c61777313.cfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler():GetLevel())
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果①的效果处理：使这张卡的等级直到回合结束时变成与送去墓地的怪兽相同
function c61777313.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级直到回合结束时变成和送去墓地的怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
	end
end
