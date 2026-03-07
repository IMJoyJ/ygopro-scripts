--大陰陽師 タオ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：这张卡被送去墓地的场合，以「大阴阳师 道」以外的自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是幻想魔族怪兽不能从墓地特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①战斗时不会被破坏的效果和②被送去墓地时的特殊召唤效果
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
	-- ②：这张卡被送去墓地的场合，以「大阴阳师 道」以外的自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是幻想魔族怪兽不能从墓地特殊召唤。
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
-- 判断目标是否为自身或战斗中的对方怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 筛选墓地中的幻想魔族怪兽，且满足特殊召唤条件且不是自身
function s.filter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsCode(id)
end
-- 判断是否满足特殊召唤的条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果并设置后续限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽存在于场上则将其特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置回合结束时禁止非幻想魔族怪兽从墓地特殊召唤的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.slim)
	-- 将禁止特殊召唤的效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否为墓地中的非幻想魔族怪兽
function s.slim(e,c,sp,st,spos,tp,se)
	return c:IsLocation(LOCATION_GRAVE) and not c:IsRace(RACE_ILLUSION)
end
