--陰陽師 タオタオ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：自己因战斗·效果受到伤害的场合才能发动。从自己的手卡·墓地把1只3星以上的幻想魔族怪兽特殊召唤。受到的伤害是2000以上的场合，也能从卡组·额外卡组选特殊召唤的怪兽。
local s,id,o=GetID()
-- 定义初始效果注册函数：创建①效果的场地永续效果e1，使这张卡与进行战斗的怪兽均不会被那次战斗破坏；创建②效果的诱发选发效果e2，在自己因战斗或效果受到伤害时，可从手卡/墓地（伤害2000以上时还可从卡组/额外卡组）特殊召唤1只3星以上的幻想魔族怪兽，并受同名卡1回合1次限制。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己因战斗·效果受到伤害的场合才能发动。从自己的手卡·墓地把1只3星以上的幻想魔族怪兽特殊召唤。受到的伤害是2000以上的场合，也能从卡组·额外卡组选特殊召唤的怪兽。
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
-- 为①效果设定目标判定：当某只怪兽c是效果持有者自身或其战斗对象时，返回true，使这2只卡获得那次战斗不被破坏的保护。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ②效果的发动条件：伤害承受方是这张卡的操控者（ep==tp），且造成伤害的原因包含战斗伤害或效果伤害（bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0），满足‘自己因战斗·效果受到伤害’的发动时机。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 定义特殊召唤候选卡的过滤条件：必须是等级3以上、种族为幻想魔族的怪兽，且能够被玩家tp特殊召唤（满足苏生限制等条件）；同时根据其来源位置判断场地空格：非额外卡组怪兽需要主要怪兽区有空位，额外卡组怪兽需要额外怪兽区（或可用赋予的额外区域）能容纳。
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(3) and c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 当候选怪兽位于手卡·墓地·卡组等非额外卡组区域时，要求己方主要怪兽区存在可用的空格（Duel.GetLocationCount(tp,LOCATION_MZONE)>0），以保证有位置进行特殊召唤。
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 当候选怪兽来自额外卡组时，要求特殊召唤后有可用的额外怪兽区（或其他额外区域），通过Duel.GetLocationCountFromEx检查从额外卡组特殊召唤是否具备空地，满足当前怪兽的出场所需条件。
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的发动目标阶段：先按受到的伤害ev设定可选来源区域（默认手卡+墓地；若伤害≥2000则加上卡组+额外卡组），并检查这些区域中是否存在1只满足s.spfilter的怪兽，若存在则允许发动；之后通过SetOperationInfo登记本次特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND+LOCATION_GRAVE
	if ev>=2000 then loc=loc+LOCATION_DECK+LOCATION_EXTRA end
	-- 在发动合法性检查（chk==0）时，使用Duel.IsExistingMatchingCard确认在loc区域中存在至少1只符合条件的幻想魔族怪兽，以此判断该效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	-- 登记连锁操作信息：向系统声明本效果将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），预定处理1张卡，候选范围来自玩家tp的loc区域，供其他卡或效果（如星尘龙、王家长眠之谷等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
-- ②效果的实际处理：再次根据伤害值确定可选的来源区域，弹出选择提示，用排除王家长眠之谷影响的过滤器选出1只符合条件的怪兽，若选择成功则以表侧表示特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND+LOCATION_GRAVE
	if ev>=2000 then loc=loc+LOCATION_DECK+LOCATION_EXTRA end
	-- 向玩家发送选择提示缓存：弹出‘请选择要特殊召唤的卡’的提示，用于后续SelectMatchingCard选择界面的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家tp的loc区域中选择1张满足s.spfilter且不受王家长眠之谷效果影响的怪兽作为特殊召唤对象（使用aux.NecroValleyFilter包装过滤器，避免从墓地选取被谷无效的怪兽）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到玩家tp的场上（特殊召唤成功，并会正常适用召唤限制/苏生限制的检查结果）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
