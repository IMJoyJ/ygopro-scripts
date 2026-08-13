--海造賊－白髭の機関士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，自己场上的这张卡当作装备卡使用给那只怪兽装备。
-- ②：这张卡从手卡·怪兽区域送去墓地的场合才能发动。从卡组把「海造贼-白胡子机关士」以外的1只「海造贼」怪兽特殊召唤。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
function c31374201.initial_effect(c)
	-- ①：对方回合才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，自己场上的这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31374201,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,31374201)
	e1:SetCondition(c31374201.spcon1)
	e1:SetTarget(c31374201.sptg1)
	e1:SetOperation(c31374201.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·怪兽区域送去墓地的场合才能发动。从卡组把「海造贼-白胡子机关士」以外的1只「海造贼」怪兽特殊召唤。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31374201,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,31374202)
	e2:SetCondition(c31374201.spcon2)
	e2:SetTarget(c31374201.sptg2)
	e2:SetOperation(c31374201.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：仅在对方回合且此卡在自己怪兽区域时才能发动（对应“对方回合才能发动”）。
function c31374201.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合（当前回合玩家不是此卡控制者），用于①效果的发动条件。
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义①效果的辅助过滤：检查对方场上表侧表示或墓地的怪兽，并确认额外卡组中存在至少1只属性与该怪兽相同且满足特殊召唤条件的「海造贼」怪兽。
function c31374201.cfilter(c,e,tp)
	-- 过滤条件：c是对方场上表侧表示或墓地的怪兽，且额外卡组存在属性与c相同、可特殊召唤的「海造贼」怪兽。
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and Duel.IsExistingMatchingCard(c31374201.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute())
end
-- 定义①效果中额外卡组怪兽的筛选：必须是「海造贼」怪兽，属性与指定属性相同，满足特殊召唤条件，且额外卡组怪兽有可用上场区域。
function c31374201.spfilter1(c,e,tp,attr)
	-- 筛选条件：c是「海造贼」怪兽，属性等于attr（对方怪兽的属性），可以被特殊召唤，并且有额外卡组怪兽可以上场的空格。
	return c:IsSetCard(0x13f) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①效果发动时点处理：检查自己魔陷区是否有空位（用于放置装备卡），以及对方场上表侧表示或墓地是否存在至少1只能满足属性匹配的怪兽。
function c31374201.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点确认：自己魔陷区是否有空位（用于之后把此卡作为装备卡装备）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且对方场上表侧表示或墓地存在至少1只怪兽，使额外卡组中能找到属性与其相同的「海造贼」怪兽可特殊召唤。
		and Duel.IsExistingMatchingCard(c31374201.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp) end
	-- 登记本次效果将进行从额外卡组特殊召唤1只怪兽的操作信息，供连锁/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 登记本次效果将把此卡作为装备卡装备的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义①效果处理时的辅助过滤：对方场上表侧表示或墓地的怪兽。
function c31374201.cfilter2(c)
	return c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
-- ①效果处理：先汇总对方场上表侧表示/墓地怪兽的所有属性，再从额外卡组选择属性匹配的「海造贼」怪兽特殊召唤；成功后把此卡装备给那只怪兽，并为该装备加上只能装备给那只怪兽的限制。
function c31374201.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上表侧表示或墓地的所有怪兽组，用于收集属性。
	local g=Duel.GetMatchingGroup(c31374201.cfilter2,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	local tc=g:GetFirst()
	local attr=0
	while tc do
		attr=attr|tc:GetAttribute()
		tc=g:GetNext()
	end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只属性与对方怪兽属性集合匹配、且满足特殊召唤条件的「海造贼」怪兽。
	local sg=Duel.SelectMatchingCard(tp,c31374201.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,attr)
	local sc=sg:GetFirst()
	-- 若选中怪兽且特殊召唤成功、该怪兽表侧表示、此卡仍与效果相关并受自己控制时，继续执行装备处理。
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 and sc:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) then
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 将此卡作为装备卡装备给那只特殊召唤的怪兽；若装备失败则中断处理。
		if not Duel.Equip(tp,c,sc,false) then return end
		-- 自己场上的这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(sc)
		e1:SetValue(c31374201.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 定义该装备卡的装备限制：只能装备给本次特殊召唤的那只怪兽（通过LabelObject记录该怪兽）。
function c31374201.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果的发动条件：此卡从手卡或怪兽区域被送去墓地的场合才能发动。
function c31374201.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE)
end
-- 定义②效果从卡组特殊召唤的怪兽条件：是「海造贼」怪兽、卡名不是「海造贼-白胡子机关士」、且可被特殊召唤。
function c31374201.spfilter2(c,e,tp)
	return c:IsSetCard(0x13f) and not c:IsCode(31374201) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时点处理：确认自己主要怪兽区有空位，且卡组存在符合条件的「海造贼」怪兽；登记操作信息为从卡组特殊召唤1只怪兽。
function c31374201.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点确认：自己主要怪兽区存在空位，且卡组中存在符合特殊召唤条件的「海造贼」怪兽（且不是本卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c31374201.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果将进行从卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的「海造贼」怪兽特殊召唤，并给自己附加“这个回合不是「海造贼」怪兽不能特殊召唤”的限制。
function c31374201.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己主要怪兽区仍有空位则继续特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只符合条件的「海造贼」怪兽（不是本卡且可特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,c31374201.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是「海造贼」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31374201.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不是「海造贼」怪兽不能特殊召唤”的限制效果注册给自己，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制条件：不能特殊召唤不是「海造贼」字段的怪兽。
function c31374201.splimit(e,c)
	return not c:IsSetCard(0x13f)
end
