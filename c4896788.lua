--強欲な壺の精霊
-- 效果：
-- ①：「强欲之壶」发动的场合发动。那个把「强欲之壶」发动的玩家可以从卡组抽1张。这个效果在这张卡在怪兽区域表侧攻击表示存在的场合进行发动和处理。
function c4896788.initial_effect(c)
	-- ①：「强欲之壶」发动的场合发动。那个把「强欲之壶」发动的玩家可以从卡组抽1张。这个效果在这张卡在怪兽区域表侧攻击表示存在的场合进行发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c4896788.drcon)
	e2:SetOperation(c4896788.drop)
	c:RegisterEffect(e2)
end
-- 条件判断：只有这张卡在怪兽区域表侧攻击表示，且连锁的效果是「强欲之壶」作为魔法卡的发动时，本效果的条件才成立。
function c4896788.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(55144522)
end
-- 效果处理：先确认这张卡仍在怪兽区域表侧攻击表示且与连锁效果仍有关联，然后让发动「强欲之壶」的玩家（rp）选择是否抽1张卡。
function c4896788.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsAttackPos() or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 若该玩家可以抽卡且选择“是”，则进行抽卡处理；若不能抽卡或选择“否”，则本效果不抽卡。
	if Duel.IsPlayerCanDraw(rp,1) and Duel.SelectYesNo(rp,aux.Stringid(4896788,0)) then  --"是否使用「强欲之壶的精灵」的效果抽卡？"
		-- 令发动「强欲之壶」的玩家以效果原因抽1张卡。
		Duel.Draw(rp,1,REASON_EFFECT)
	end
end
