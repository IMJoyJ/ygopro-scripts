--死の演算盤
-- 效果：
-- 每次怪兽从场上送去墓地，每1张卡使那张卡的主人受到500分的伤害。
function c77910045.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次怪兽从场上送去墓地，每1张卡使那张卡的主人受到500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c77910045.operation)
	c:RegisterEffect(e2)
end
-- 过滤出原本在怪兽区域、属于指定玩家且是怪兽卡的卡片
function c77910045.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 分别统计双方玩家从场上送去墓地的怪兽数量，并给与对应玩家每张卡500分的伤害
function c77910045.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c77910045.filter,nil,tp)
	if ct>0 then
		-- 给与玩家tp因效果造成的伤害，数值为该玩家送去墓地的怪兽数量乘以500
		Duel.Damage(tp,500*ct,REASON_EFFECT)
	end
	ct=eg:FilterCount(c77910045.filter,nil,1-tp)
	if ct>0 then
		-- 给与玩家1-tp（对方玩家）因效果造成的伤害，数值为该玩家送去墓地的怪兽数量乘以500
		Duel.Damage(1-tp,500*ct,REASON_EFFECT)
	end
end
