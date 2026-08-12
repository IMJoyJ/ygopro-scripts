--キラーチューン・クリップ
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，对方主要阶段才能发动。这张卡特殊召唤。那之后，可以进行1只同调怪兽调整的同调召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。对方的额外卡组的里侧的卡随机1张除外。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：手牌调整同调、特殊召唤并同调召唤、作为同调素材时除外对方额外卡组的1张卡
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- 这张卡在手卡存在的场合，对方主要阶段才能发动。这张卡特殊召唤。那之后，可以进行1只同调怪兽调整的同调召唤
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
	-- 这张卡作为同调素材送去墓地的场合才能发动。对方的额外卡组的里侧的卡随机1张除外
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
-- 过滤函数，用于判断是否为同步素材的调整怪兽
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 条件函数，判断该卡是否在场上
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 条件函数，判断是否为对方主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方主要阶段才能发动
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()==1-tp
end
-- 特殊召唤的发动时点判定函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于判断是否为可进行同调召唤的调整怪兽
function s.spfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSynchroSummonable(nil)
end
-- 特殊召唤并同调召唤的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否能被特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 刷新场上信息
		Duel.AdjustAll()
		-- 判断额外卡组是否存在可同调召唤的调整怪兽
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil)
			-- 询问玩家是否进行同调召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行同调召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 获取额外卡组中所有满足条件的调整怪兽
			local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil)
			if g:GetCount()>0 then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 进行同调召唤
				Duel.SynchroSummon(tp,sg:GetFirst(),nil)
			end
		end
	end
end
-- 作为同调素材的条件函数
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于判断是否为可除外的里侧卡
function s.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 除外效果的发动时点判定函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方额外卡组是否存在可除外的里侧卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
end
-- 除外效果的处理函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中所有满足条件的里侧卡
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(tp,1)
		-- 将选定的卡除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
