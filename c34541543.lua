--大陰陽師 タオ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：这张卡被送去墓地的场合，以「大阴阳师 道」以外的自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是幻想魔族怪兽不能从墓地特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①为场地永续效果，使这张卡及其战斗对象不会被战斗破坏；②为送墓时诱发的选发效果（1回合1次），可以特殊召唤墓地幻想魔族怪兽，并在发动后附加不能从墓地特殊召唤非幻想魔的自肃。
function s.initial_effect(c)
	-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的场合，以「大阴阳师 道」以外的自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的判定函数：若要被战斗破坏的卡是这张卡自身或这张卡的战斗对象，则返回true，使这2只怪兽不被那次战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ②效果的对象筛选：从自己墓地筛选出不是「大阴阳师 道」、种族为幻想魔族、且可以被当前效果以表侧守备表示特殊召唤的怪兽。
function s.filter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsCode(id)
end
-- ②效果的发动/对象判断：若在连锁过程中检查对象，则要求该对象位于自己墓地且满足s.filter；若在发动时检查，则需要自己主要怪兽区有空位且墓地存在至少1只满足s.filter的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 发动条件检查：自己场上是否有可用的主要怪兽区，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地是否存在至少1只满足s.filter的幻想魔族怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示文本为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足s.filter的怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁处理1张怪兽卡的特殊召唤，对象为刚刚选择的g，供其他效果查询。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将作为对象的墓地怪兽以表侧守备表示特殊召唤到自己场上；随后给发动玩家注册一个直到结束阶段有效的效果，使其不能从墓地特殊召唤非幻想魔族怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中通过选卡设置的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果关联（未被移走或失效），则将其以表侧守备表示特殊召唤到自己场上。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 这个效果的发动后，直到回合结束时自己不是幻想魔族怪兽不能从墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.slim)
	-- 将上述自肃效果注册给发动玩家tp，使其从此刻起到回合结束受到该召唤限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：当从墓地特殊召唤的怪兽位于墓地且不是幻想魔族怪兽时返回true，表示禁止这次特殊召唤。
function s.slim(e,c,sp,st,spos,tp,se)
	return c:IsLocation(LOCATION_GRAVE) and not c:IsRace(RACE_ILLUSION)
end
