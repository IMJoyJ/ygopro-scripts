--ヘル・ダイブ・ボンバー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段2才能发动。场上的表侧表示怪兽全部破坏，给与对方破坏的怪兽的原本等级合计×200伤害。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只5星以下的机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、①效果（主要阶段2破坏场上表侧表示怪兽并给与伤害）和②效果（被破坏时特殊召唤墓地机械族怪兽）。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段2才能发动。场上的表侧表示怪兽全部破坏，给与对方破坏的怪兽的原本等级合计×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.decon)
	e1:SetTarget(s.detg)
	e1:SetOperation(s.deop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1只5星以下的机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数，限制在主要阶段2发动。
function s.decon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的发动准备（Target）函数，检查场上是否存在表侧表示怪兽，并设置破坏与伤害的操作信息。
function s.detg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，判定场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有表侧表示的怪兽。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置破坏的操作信息，包含要破坏的怪兽组及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	local dmg=sg:GetSum(Card.GetOriginalLevel)*200
	if dmg>0 then
		-- 设置伤害的操作信息，给与对方玩家原本等级合计×200的伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
	end
end
-- 过滤用于计算原本等级的卡片（必须是原本为怪兽的卡，或者因效果特殊召唤的卡，防止陷阱怪兽等非怪兽卡在墓地无法获取原本等级）。
function s.lvcalfilter(c)
	if c:GetOriginalType()&TYPE_MONSTER~=0 then return true end
	local se=c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
	return se and se:GetHandler()==c
end
-- ①效果的执行（Operation）函数，破坏场上所有表侧表示怪兽，并给与对方被破坏怪兽原本等级合计×200的伤害。
function s.deop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的怪兽。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		local cg=sg:Filter(s.lvcalfilter,nil)
		-- 尝试因效果破坏这些怪兽，并判断是否有怪兽被成功破坏。
		if Duel.Destroy(sg,REASON_EFFECT)>0 then
			-- 计算实际被破坏且符合等级计算条件的怪兽的原本等级合计。
			local ct=(Duel.GetOperatedGroup()&cg):GetSum(Card.GetOriginalLevel)
			-- 给与对方玩家计算出的等级合计×200的伤害。
			Duel.Damage(1-tp,ct*200,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件判定函数，检查这张卡是否被战斗或效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤自己墓地中5星以下的机械族怪兽，且该怪兽可以守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动准备（Target）函数，进行怪兽区域空格检查、墓地目标怪兽合法性检查，并选择目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 在发动检查时，判定自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且判定自己墓地是否存在至少1只满足条件的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标怪兽和数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的执行（Operation）函数，将选择的墓地怪兽守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与连锁相关，且不受王家长眠之谷的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
