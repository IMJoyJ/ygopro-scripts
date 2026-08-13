--破械習合
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以包含自己场上的「破械神」连接怪兽的自己·对方场上2只表侧表示怪兽为对象才能发动。只用那2只怪兽为素材进行1只恶魔族连接怪兽的连接召唤。
-- ②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①发动时的连接召唤效果（取对象，1回合1次）；②作为魔法陷阱卡被效果破坏时的特殊召唤效果（1回合1次）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以包含自己场上的「破械神」连接怪兽的自己·对方场上2只表侧表示怪兽为对象才能发动。只用那2只怪兽为素材进行1只恶魔族连接怪兽的连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"连接召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 用于选择对象的过滤条件：怪兽必须表侧表示且能被效果取为对象。
function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 用于在所选怪兽中确认至少存在1只自己场上的表侧表示「破械神」连接怪兽。
function s.lkfilter(c,tp)
	return c:IsSetCard(0x1130) and c:IsType(TYPE_LINK) and c:IsControler(tp)
end
-- 检查所选2只怪兽是否满足：其中至少1只是自己场上的「破械神」连接怪兽，并且额外卡组存在能用这2只怪兽作为素材进行连接召唤的恶魔族连接怪兽。
function s.sgselect(g,tp)
	return g:IsExists(s.lkfilter,1,nil,tp)
		-- 额外卡组存在1只可用这2只怪兽为素材进行连接召唤的恶魔族连接怪兽。
		and Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 额外卡组中作为连接召唤候选的过滤条件：必须是恶魔族连接怪兽，且能用所选的2只怪兽作为素材进行连接召唤（素材数正好2只）。
function s.lfilter(c,mg)
	return c:IsRace(RACE_FIEND) and c:IsLinkSummonable(mg,nil,2,2)
end
-- 发动时处理：从双方怪兽区域筛选出所有表侧表示且可为效果对象的怪兽，检查是否存在满足条件的2只组合；若存在则提示玩家选择2只，将所选怪兽设为对象，并设置从额外卡组特殊召唤1只的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己·对方场上满足s.filter（表侧表示且可作为效果对象）的全部怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.sgselect,2,2,tp) end
	-- 向玩家显示选择效果对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.sgselect,false,2,2,tp)
	-- 将选择的2只怪兽登记为这张卡发动时的对象。
	Duel.SetTargetCard(sg)
	-- 设置连锁的操作信息：本次处理会进行1只怪兽的特殊召唤，召唤来源为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时确认对象仍然在怪兽区域表侧表示，且不对此效果免疫，这样的怪兽才能继续作为连接素材。
function s.mtfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and not c:IsImmuneToEffect(e)
end
-- 效果处理：取出发动时选择的对象；若对象仍为2只且都可作为素材，则从额外卡组选择1只恶魔族连接怪兽，用这2只怪兽作为素材进行连接召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象（与当前连锁相关的对象）。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()==2 and g:IsExists(s.mtfilter,2,nil,tp,e) then
		-- 向玩家显示选择要特殊召唤的卡的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只可用这2只怪兽作为素材连接召唤的恶魔族连接怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.lfilter,tp,LOCATION_EXTRA,0,1,1,nil,g)
		local lc=sg:GetFirst()
		if lc then
			-- 以对象怪兽作为素材，将选择的连接怪兽进行连接召唤（素材数恰好2只）。
			Duel.LinkSummon(tp,lc,g,nil,2,2)
		end
	end
end
-- 第②效果的发动条件：这张卡以里侧表示存在于场上，并且被效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 从卡组特殊召唤的候选过滤条件：卡名含有「破械」的怪兽，并且能够用效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 第②效果的发动判定：自己怪兽区域有空位，且卡组中存在可以特殊召唤的「破械」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只以上符合条件的「破械」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：本次效果处理会从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 第②效果的处理：若自己怪兽区域存在空位，则从卡组选择1只「破械」怪兽，将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己怪兽区域没有空位，则特殊召唤处理不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择要特殊召唤的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「破械」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
