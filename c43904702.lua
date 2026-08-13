--キラーチューン・クリップ
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，对方主要阶段才能发动。这张卡特殊召唤。那之后，可以进行1只同调怪兽调整的同调召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。对方的额外卡组的里侧的卡随机1张除外。
local s,id,o=GetID()
-- 初始化效果函数：依次注册该卡的3个效果——①作为同调素材时允许手卡调整怪兽作为同调素材的手牌同步效果；②对方主要阶段从手卡特殊召唤并可选追加同调召唤；③作为同调素材送墓时除外对方额外卡组里侧1张卡。
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在的场合，对方主要阶段才能发动。这张卡特殊召唤。那之后，可以进行1只同调怪兽调整的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。对方的额外卡组的里侧的卡随机1张除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外额外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	s.killer_tune_be_material_effect=e3
end
-- 手牌同调素材的过滤函数：仅允许调整怪兽作为手牌同调素材。
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 手牌同调素材效果的适用条件：此卡在主要怪兽区存在。
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：仅在对方主要阶段，且当前回合玩家为对方时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于对方主要阶段（Duel.IsMainPhase()为真且回合玩家不是自己）。
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()==1-tp
end
-- 效果①的发动目标：检查自己主要怪兽区有可用空格，且此卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件成立：自己主要怪兽区存在空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将特殊召唤此卡，用于发动后的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 追加同调召唤的候选过滤：选择额外卡组中为调整怪兽且可以当前素材进行同调召唤的怪兽（即同调怪兽调整）。
function s.spfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSynchroSummonable(nil)
end
-- 效果①处理：先特殊召唤此卡；成功后询问玩家是否进行追加同调召唤，若选择是则从额外卡组选1只符合条件的调整同调怪兽进行同调召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡仍与当前连锁相关，且特殊召唤成功（返回实际召唤数非0）后继续后续操作。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 刷新场地信息，使刚特殊召唤的此卡被正确识别为场上卡片，为后续同调召唤的判断做准备。
		Duel.AdjustAll()
		-- 检查额外卡组中是否存在可追加同调召唤的调整同调怪兽。
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil)
			-- 询问玩家是否进行追加的同调召唤（是/否）。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行同调召唤？"
			-- 中断当前效果处理，使接下来的同调召唤作为独立动作，避免因连锁处理中的时点限制而无法发动同调召唤。
			Duel.BreakEffect()
			-- 获取额外卡组中所有满足条件的调整同调怪兽。
			local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil)
			if g:GetCount()>0 then
				-- 向玩家发送选择提示，要求选择要同调召唤的怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 执行同调召唤手续，将选中的调整同调怪兽召唤出场（tuner参数为nil，表示自动选择场上的调整素材）。
				Duel.SynchroSummon(tp,sg:GetFirst(),nil)
			end
		end
	end
end
-- 效果②的发动条件：此卡作为同调素材被送去墓地。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 选择对象过滤：对方额外卡组中里侧表示且可以被除外的卡。
function s.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果②的发动目标：确认对方额外卡组存在符合条件的里侧卡，并设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检测：对方额外卡组中是否存在里侧且可除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置操作信息：本次效果将从对方额外卡组随机除外1张卡（targets为nil，因为对象在效果处理时随机确定）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理：随机选择对方额外卡组1张里侧卡并除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中所有里侧且可除外的卡。
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(tp,1)
		-- 将随机选中的那张卡以表侧表示除外，除外原因记为效果。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
