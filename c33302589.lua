--セイクリッド・カストル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把「星圣·北河二」以外的1只「星圣」怪兽特殊召唤。这个回合，自己不是光·暗属性怪兽不能从额外卡组特殊召唤。
-- ②：有这张卡在作为超量素材中的「星圣」超量怪兽得到以下效果。
-- ●1回合1次，对方把魔法卡的效果发动时才能发动。自己场上2个超量素材取除，那个效果无效并破坏。
local s,id,o=GetID()
-- 注册“星圣·北河二”的全部效果：①效果（召唤·反转召唤·特殊召唤时从卡组特召1只其他「星圣」怪兽）以及②效果（作为超量素材时让星圣超量怪兽获得“对方魔法卡发动时取除2个超量素材将其无效并破坏”的即时效果）。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把「星圣·北河二」以外的1只「星圣」怪兽特殊召唤。这个回合，自己不是光·暗属性怪兽不能从额外卡组特殊召唤。
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
-- 定义特殊召唤的过滤条件：需为「星圣」怪兽、不是「星圣·北河二」、且能够通过效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x53) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件：自己场上存在可用的主要怪兽区，且卡组中存在符合条件的「星圣」怪兽可供特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足 s.spfilter 条件的「星圣」怪兽（排除 exc 指定的卡）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,exc,e,tp) end
	-- 设置特殊召唤的操作信息，告知系统本效果将从卡组特殊召唤1只怪兽到持有者场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若仍有空位则从卡组选择1只符合条件的「星圣」怪兽表侧表示特殊召唤；随后给己方玩家附加“这个回合不能从额外卡组特殊召唤非光·暗属性怪兽”的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有空余的主要怪兽区。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1张满足条件的「星圣」怪兽（除「星圣·北河二」）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是光·暗属性怪兽不能从额外卡组特殊召唤。②：有这张卡在作为超量素材中的「星圣」超量怪兽得到以下效果。●1回合1次，对方把魔法卡的效果发动时才能发动。自己场上2个超量素材取除，那个效果无效并破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果以玩家为对象注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定条件：要特殊召唤的怪兽不是光属性也不是暗属性，且从额外卡组特殊召唤（即禁止此类特殊召唤）。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：持有者是「星圣」超量怪兽、该怪兽未被战斗破坏、对方发动魔法卡效果、且该连锁效果可以被无效。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x53)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 进一步确认对方发动的效果是魔法卡效果，并且该连锁可以被我方无效。
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
end
-- ②效果的发动目标与操作信息设置：检查自己场上是否有2个超量素材可取除；向对方提示发动；设置无效/破坏的对象信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否有至少2个超量素材可以取除（作为发动代价/处理前提）。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_EFFECT) end
	-- 向对方玩家提示我方发动了这个效果（显示效果描述文本）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：要将正在发动的魔法卡（eg）的效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该魔法卡可被破坏且仍与效果关联，则追加设置操作信息：将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：实际取除自己场上2个超量素材，成功后无效对方发动的魔法卡效果，并将其破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试取除自己场上2个超量素材，成功时返回值大于0才继续处理。
	if Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_EFFECT)>0
		-- 无效该连锁的效果，并确认被无效的魔法卡仍在连锁中（未被除外/离场）。
		and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将对方发动的那张魔法卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
