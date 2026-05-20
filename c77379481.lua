--大盤振舞侍
-- 效果：
-- 这张卡给与对方战斗伤害时，对方玩家将手卡抽到7张为止。
function c77379481.initial_effect(c)
	-- 这张卡给与对方战斗伤害时，对方玩家将手卡抽到7张为止。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77379481,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c77379481.condition)
	e1:SetTarget(c77379481.target)
	e1:SetOperation(c77379481.operation)
	c:RegisterEffect(e1)
end
-- 确认受到战斗伤害的是对方玩家。
function c77379481.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的目标确认，设置对方为目标玩家，并根据其手卡数量预设抽卡操作信息。
function c77379481.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设定为效果的对象玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 获取对方玩家的手卡数量。
	local ht=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ht<7 then
		-- 设置连锁的操作信息，动作为抽卡，对象为对方玩家，数量为7减去对方当前手卡数。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,7-ht)
	end
end
-- 效果处理的执行，使目标玩家将手卡抽到7张为止。
function c77379481.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该对象玩家当前的手卡数量。
	local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if ht<7 then
		-- 让该玩家因效果抽卡，抽到手卡为7张为止（即抽 7-ht 张卡）。
		Duel.Draw(p,7-ht,REASON_EFFECT)
	end
end
