--強欲な壺の精霊
-- 效果：
-- ①：「强欲之壶」发动的场合发动。那个把「强欲之壶」发动的玩家可以从卡组抽1张。这个效果在这张卡在怪兽区域表侧攻击表示存在的场合进行发动和处理。
function c4896788.initial_effect(c)
	-- 效果原文内容：①：「强欲之壶」发动的场合发动。那个把「强欲之壶」发动的玩家可以从卡组抽1张。这个效果在这张卡在怪兽区域表侧攻击表示存在的场合进行发动和处理。
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
-- 规则层面操作：检查触发效果的卡是否为「强欲之壶」的发动，且当前精灵怪兽处于攻击表示
function c4896788.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(55144522)
end
-- 规则层面操作：判断精灵怪兽是否仍存在于场上且处于攻击表示，若满足条件则询问玩家是否使用效果抽卡
function c4896788.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsAttackPos() or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 规则层面操作：检查目标玩家是否可以抽卡并由其选择是否使用「强欲之壶的精灵」的效果抽卡
	if Duel.IsPlayerCanDraw(rp,1) and Duel.SelectYesNo(rp,aux.Stringid(4896788,0)) then  --"是否使用「强欲之壶的精灵」的效果抽卡？"
		-- 规则层面操作：执行让指定玩家抽一张卡的效果
		Duel.Draw(rp,1,REASON_EFFECT)
	end
end
