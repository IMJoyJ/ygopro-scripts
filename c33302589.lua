--セイクリッド・カストル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把「星圣·北河二」以外的1只「星圣」怪兽特殊召唤。这个回合，自己不是光·暗属性怪兽不能从额外卡组特殊召唤。
-- ②：有这张卡在作为超量素材中的「星圣」超量怪兽得到以下效果。
-- ●1回合1次，对方把魔法卡的效果发动时才能发动。自己场上2个超量素材取除，那个效果无效并破坏。
local s,id,o=GetID()
-- 创建并注册效果：通常召唤成功时发动，从卡组特殊召唤1只「星圣」怪兽，且本回合不能从额外卡组特殊召唤非光·暗属性怪兽
function s.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把「星圣·北河二」以外的1只「星圣」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	s.star_knight_summon_effect=e1
	-- ②：有这张卡在作为超量素材中的「星圣」超量怪兽得到以下效果。●1回合1次，对方把魔法卡的效果发动时才能发动。自己场上2个超量素材取除，那个效果无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"魔法卡的效果发动无效（星圣·北河二）"
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- 过滤函数：用于检索满足条件的「星圣」怪兽（不包括自身），可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x53) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件：检查场上是否有空位且卡组是否存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,exc,e,tp) end
	-- 设置操作信息：准备特殊召唤1只「星圣」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤处理函数：若场上存在空位，则选择1只满足条件的怪兽特殊召唤，并设置本回合不能从额外卡组特殊召唤非光·暗属性怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 创建并注册效果：本回合不能从额外卡组特殊召唤非光·暗属性怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：判断是否为非光·暗属性且位于额外卡组的怪兽
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
-- 无效效果发动条件函数：检查是否为「星圣」怪兽、未被战斗破坏、对方发动魔法卡且该效果可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x53)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 对方发动的是魔法卡且该效果可被无效
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
end
-- 无效效果处理函数：检查是否能移除2个超量素材，设置操作信息为无效和破坏
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能移除2个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_EFFECT) end
	-- 提示对方选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏对方发动的魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果处理函数：移除2个超量素材，使效果无效并破坏对方发动的魔法卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除2个超量素材成功
	if Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_EFFECT)>0
		-- 使效果无效且对方发动的魔法卡存在
		and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏对方发动的魔法卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
