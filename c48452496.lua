--蛇眼の炎龍
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己或对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：对方回合，以场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
-- ③：这张卡从手卡·场上送去墓地的场合才能发动。从自己墓地把2只炎属性·1星怪兽特殊召唤。
local s,id,o=GetID()
-- 为蛇眼炎龙注册3个效果：①起动效果，1回合1次，取对象把场上（表侧表示）·墓地的怪兽放置到其原本持有者的魔陷区；②诱发即时效果，仅对方回合1次，取对象把场上当作永续魔法使用的怪兽卡特召到自己场上；③诱发选发效果，从手牌·场上送墓时1次，从自己墓地特召2只炎属性·1星怪兽。
function s.initial_effect(c)
	-- ①：以自己或对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spscon)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
	-- ③：这张卡从手卡·场上送去墓地的场合才能发动。从自己墓地把2只炎属性·1星怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①选取对象的过滤条件：对象必须是场上（表侧表示）或墓地的怪兽，不是禁止卡，同名卡在场上不超限，且其原本持有者魔陷区有空位；若该卡控制权与持有者不同，则按控制权变动处理可用格子的判定（凯撒竞技场等）。
function s.filter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then r=LOCATION_REASON_CONTROL end
	return (c:IsLocation(LOCATION_MZONE) or c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner()))
		-- 对象还必须是场上表侧表示或位于墓地的怪兽，并且其原本持有者魔陷区存在空位；r 会根据控制权与持有者是否一致来选择 LOCATION_REASON_TOFIELD 或 LOCATION_REASON_CONTROL，以适配区域限制。
		and c:IsFaceupEx() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- 效果①发动时：从双方场上（表侧表示）·墓地选择1只满足条件的怪兽作为对象，优先选择场上的目标；若选中的目标是墓地怪兽，则额外登记本次操作会使卡片离开墓地，供王家长眠之谷等效果检测。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and s.filter(chkc,tp) end
	-- 效果①发动判定：确认双方场上（表侧表示）·墓地存在至少1只满足 s.filter 的怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil,tp) end
	-- 向选择方显示“请选择效果的对象”的提示消息，用于选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从场上（表侧表示）·墓地中选择1只满足条件的怪兽作为对象；优先选择场上的目标，场上没有合法目标时才从墓地选择，并将所选卡登记为当前连锁的对象。
	local g=aux.SelectTargetFromFieldFirst(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil,tp)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 当选择的目标位于墓地时，设置操作信息为 CATEGORY_LEAVE_GRAVE，使相关卡（如王家长眠之谷）能正确响应这次从墓地移动的处理。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果①处理时：取得对象怪兽，若对象仍与效果关联且不免疫此效果，则将其移动到其原本持有者的魔法与陷阱区域并表侧放置，同时附加改变种类为永续魔法（TYPE_SPELL+TYPE_CONTINUOUS）的效果，使其当作永续魔法卡使用。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 将对象怪兽移动到其原本持有者的魔法与陷阱区域，以表侧表示放置并立即生效；移动成功后才继续执行种类变更。
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：仅在对方回合（当前回合玩家不是效果发动者）可以发动。
function s.spscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是效果发动者的对手，以满足“对方回合”的发动条件。
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②选取对象的过滤条件：卡片原始种类必须是怪兽，当前种类为永续魔法（即被①变成的魔法卡），处于表侧表示，并且可以被发动者特殊召唤。
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:GetType()&TYPE_CONTINUOUS+TYPE_SPELL==TYPE_CONTINUOUS+TYPE_SPELL
		and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②发动时：确认自己主要怪兽区有空位，并从场上选择1张“当作永续魔法卡使用的怪兽卡”作为对象；若为连锁检查 chkc 则判断该卡是否满足条件。
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.sfilter(chkc,e,tp) end
	-- 效果②发动判定：确认自己主要怪兽区域至少存在1个可用空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认双方场上存在至少1张满足 s.sfilter（原始是怪兽、当前是表侧永续魔法且可被特殊召唤）的卡可以作为对象。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) end
	-- 向发动者显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动者从双方场上选择1张满足条件的当作永续魔法使用的怪兽卡，将其设定为效果②的对象并与本次连锁建立联系。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	-- 设置本次操作为特殊召唤（CATEGORY_SPECIAL_SUMMON），并将对象卡 g 登记为预计特殊召唤的卡，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②处理时：取得对象怪兽，若该卡仍与效果关联，则将其以表侧表示特殊召唤到发动者自己场上（不检查召唤条件与苏生限制）。
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡与效果仍有联系，则将其以表侧表示特殊召唤到发动者 tp 的场上。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
-- 效果③的发动条件：这张卡从手牌或场上被送去墓地时才能发动（用 IsPreviousLocation 判定此前位置是手牌或场上）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 效果③选取墓地怪兽的过滤条件：必须是1星、炎属性怪兽，且可以被特殊召唤（不检查苏生限制）。
function s.ffilter(c,e,tp)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③发动判定：需要自己主要怪兽区至少2个空位、自己不受“青眼精灵龙”效果影响（该效果禁止双方同时特殊召唤2只以上怪兽），且自己墓地存在至少2只满足条件的炎属性·1星怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果③发动判定：确认自己主要怪兽区域至少有2个空位，以便同时特殊召唤2只怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己墓地中至少有2只满足 s.ffilter（1星·炎属性·可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 设置操作信息：本次效果将从墓地特殊召唤2只怪兽（目标在效果处理时选择），以便相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 效果③处理时：重新确认自己主要怪兽区至少2个空位、不受“青眼精灵龙”效果影响、墓地至少有2只符合条件的怪兽；满足条件才从墓地选择2只炎属性·1星怪兽特殊召唤，否则不处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 若墓地中符合条件的炎属性·1星怪兽不足2只，则效果处理失败并直接返回。
		or Duel.GetMatchingGroupCount(s.ffilter,tp,LOCATION_GRAVE,0,nil,e,tp)<2 then return end
	-- 向发动者显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择2只满足条件的炎属性·1星怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 将选择的2只怪兽以表侧表示特殊召唤到发动者自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
