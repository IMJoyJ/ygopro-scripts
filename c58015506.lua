--ピケルの読心術
-- 效果：
-- 直到对方第2个回合的结束阶段前，对方玩家的抽卡先公开再加入手卡。
function c58015506.initial_effect(c)
	-- 直到对方第2个回合的结束阶段前，对方玩家的抽卡先公开再加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c58015506.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理：注册一个在对方第2个回合的结束阶段前持续适用的全局效果，在玩家抽卡时触发。
function c58015506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到对方第2个回合的结束阶段前，对方玩家的抽卡先公开再加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c58015506.cfop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	-- 将该持续效果注册给发动这张卡的玩家，使其作为全局效果生效。
	Duel.RegisterEffect(e1,tp)
end
-- 抽卡时的效果处理：如果抽卡玩家是对方玩家，则将抽到的卡给己方玩家确认。
function c58015506.cfop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	-- 将抽到的卡片组给另一方玩家（即发动此卡效果的玩家）进行确认。
	Duel.ConfirmCards(1-ep,eg)
end
