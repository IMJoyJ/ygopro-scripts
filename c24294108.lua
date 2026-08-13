--燃えさかる大地
-- 效果：
-- 这张卡的发动时，场上的场地魔法卡全部破坏。此外，双方的准备阶段时，回合玩家受到500分伤害。
function c24294108.initial_effect(c)
	-- 这张卡的发动时，场上的场地魔法卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24294108.target)
	e1:SetOperation(c24294108.activate)
	c:RegisterEffect(e1)
	-- 此外，双方的准备阶段时，回合玩家受到500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24294108,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetTarget(c24294108.damtg)
	e2:SetOperation(c24294108.damop)
	c:RegisterEffect(e2)
end
-- 发动时先检查是否满足发动条件（此处无条件限制），然后获取双方场地区域全部卡片，并设置要破坏的卡组及数量。
function c24294108.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场地魔法区域（LOCATION_FZONE）内的所有卡片，作为将要被破坏的对象集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	-- 设置本次连锁要进行的破坏操作信息：破坏对象为g中的所有卡，数量为g的卡数，因不取对象而不指定具体玩家和位置。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，再次获取双方场地区域的全部卡片，若数量大于0则将这些卡片全部破坏（由效果破坏）。
function c24294108.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取双方场地魔法区域内的所有卡片（用于处理时判定当前存在的场地卡）。
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if g:GetCount()>0 then
		-- 以效果原因（REASON_EFFECT）将组g中的所有卡片破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 准备阶段效果触发时的判定：无条件限制；取得当前回合玩家作为承受伤害的玩家，并设置伤害值为500，同时设置造成伤害的操作信息。
function c24294108.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前回合玩家，作为准备阶段受到伤害的玩家。
	local cp=Duel.GetTurnPlayer()
	-- 将当前连锁的对象玩家设置为该回合玩家，便于后续处理时获取。
	Duel.SetTargetPlayer(cp)
	-- 将当前连锁的对象参数设置为500，表示要造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 设置本连锁的操作信息：效果类别为伤害，对象玩家为cp，伤害值为500（由于伤害玩家已在目标玩家中确定，目标卡设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,cp,500)
end
-- 效果处理时，从当前连锁信息中取得目标玩家和伤害数值，并给该玩家造成对应的效果伤害。
function c24294108.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的伤害对象玩家和伤害值参数，赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
