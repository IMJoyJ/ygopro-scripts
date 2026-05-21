--TG ワンダー・マジシャン
-- 效果：
-- 调整＋调整以外的「科技属」怪兽1只以上
-- ①：这张卡同调召唤的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
-- ③：场上的这张卡被破坏的场合发动。自己抽1张。
function c98558751.initial_effect(c)
	-- 设置同调召唤手续：调整 + 调整以外的「科技属」怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x27),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98558751,0))  --"场上1张魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c98558751.descon)
	e1:SetTarget(c98558751.destg)
	e1:SetOperation(c98558751.desop)
	c:RegisterEffect(e1)
	-- ③：场上的这张卡被破坏的场合发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98558751,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c98558751.drcon)
	e2:SetTarget(c98558751.drtg)
	e2:SetOperation(c98558751.drop)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98558751,2))  --"同调召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c98558751.sccon)
	e3:SetTarget(c98558751.sctg)
	e3:SetOperation(c98558751.scop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡同调召唤成功
function c98558751.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：魔法或陷阱卡
function c98558751.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的靶向与操作信息设置：以场上1张魔法·陷阱卡为对象，并设置破坏操作信息
function c98558751.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c98558751.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c98558751.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理：破坏作为对象的卡
function c98558751.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡被破坏
function c98558751.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果③的靶向与操作信息设置：设置抽卡玩家、抽卡数量及抽卡操作信息
function c98558751.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的处理：自己抽1张卡
function c98558751.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果②的发动条件：对方回合的主要阶段
function c98558751.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
		-- 检查当前阶段是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②的靶向与操作信息设置：检查是否存在可以同调召唤的怪兽，并设置特殊召唤操作信息
function c98558751.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在可以用包含这张卡的场上怪兽为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：用包含这张卡的自己场上的怪兽为素材进行同调召唤
function c98558751.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以用包含这张卡的场上怪兽为素材进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 向玩家发送选择要特殊召唤的怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
