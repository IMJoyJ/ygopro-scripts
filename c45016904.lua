--陰陽師 タオタオ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：自己因战斗·效果受到伤害的场合才能发动。从自己的手卡·墓地把1只3星以上的幻想魔族怪兽特殊召唤。受到的伤害是2000以上的场合，也能从卡组·额外卡组选特殊召唤的怪兽。
local s,id,o=GetID()
-- 注册两个效果：①战斗时双方怪兽不会被战斗破坏；②自己受到战斗/效果伤害时可特殊召唤幻想魔族怪兽
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
	-- ②：自己因战斗·效果受到伤害的场合才能发动。从自己的手卡·墓地把1只3星以上的幻想魔族怪兽特殊召唤。受到的伤害是2000以上的场合，也能从卡组·额外卡组选特殊召唤的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的目标怪兽判定函数：判断目标是否为自身或自身战斗对象
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果②的发动条件函数：判断是否为己方受到战斗或效果伤害
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 特殊召唤目标怪兽的过滤函数：满足3星以上、幻想魔族、可特殊召唤、且有足够召唤空间
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(3) and c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断目标怪兽是否在额外卡组以外的位置且场上存在召唤空间
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断目标怪兽是否在额外卡组且额外召唤空间足够
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果②的发动时点处理函数：根据伤害值决定可选区域并检查是否有满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND+LOCATION_GRAVE
	if ev>=2000 then loc=loc+LOCATION_DECK+LOCATION_EXTRA end
	-- 检查是否有满足条件的怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
-- 效果②的发动处理函数：根据伤害值选择召唤区域并选择特殊召唤的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND+LOCATION_GRAVE
	if ev>=2000 then loc=loc+LOCATION_DECK+LOCATION_EXTRA end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
