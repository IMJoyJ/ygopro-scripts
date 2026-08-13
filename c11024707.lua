--回猫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡·卡组送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
-- ②：反转过的这张卡在怪兽区域存在的状态，怪兽从手卡·卡组送去自己墓地的场合，以那之内的1只为对象才能发动。那只怪兽里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册三个效果：①效果：此卡从手卡·卡组送去墓地时，里侧守备表示特殊召唤（1回合1次）；②效果：反转过的此卡在怪兽区域存在时，怪兽从手卡·卡组送去自己墓地，选其中1只里侧守备表示特殊召唤（1回合1次）；③辅助效果：翻转时记录标记，用于②的“反转过”条件。
function s.initial_effect(c)
	-- ①：这张卡从手卡·卡组送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：反转过的这张卡在怪兽区域存在的状态，怪兽从手卡·卡组送去自己墓地的场合，以那之内的1只为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- （不入连锁的辅助效果）记录此卡已反转过的状态，对应②效果中“反转过的这张卡”的条件描述。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FLIP)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.flipop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：判断这张卡是从手卡或卡组送去墓地（即之前位置为手卡·卡组）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- ①效果发动合法性检查：我方怪兽区存在空位，且这张卡可以里侧守备表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置操作信息：本次连锁处理将包含特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡与效果仍有关联，则将其里侧守备表示特殊召唤；若特殊召唤成功，对方可以确认该卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍在处理范围内且可以特殊召唤，并实际将其里侧守备表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 让对手确认这张卡（确认其卡名等信息）。
		Duel.ConfirmCards(1-tp,c)
	end
end
-- ②效果可选对象的筛选条件：该怪兽需是从手卡·卡组送去自己墓地、在自己墓地、能被里侧守备特殊召唤且能成为效果对象。
function s.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and c:IsCanBeEffectTarget(e)
end
-- ②效果发动条件：这张卡表侧表示且已有“反转过”标记，且本次送去墓地的怪兽中存在满足筛选条件的对象。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetFlagEffect(id)>0 and eg:IsExists(s.spfilter,1,nil,e,tp)
end
-- ②效果发动处理：从本次送去墓地的怪兽中选择1只符合条件的对象，并设定特殊召唤的操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.spfilter(chkc,e,tp) end
	-- 检查我方怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 显示选择提示“请选择要特殊召唤的卡”，用于让玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
	-- 将选择的卡设置为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本次连锁处理将包含特殊召唤选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：获取对象卡，若其与效果关联且不受王家长眠之谷影响，则将其里侧守备表示特殊召唤；成功时让对方确认。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的作为对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与效果关联、不受王家长眠之谷影响，并实际将其里侧守备表示特殊召唤。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 让对手确认被特殊召唤的那只怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 翻转时给这张卡设置一个标记，用于记录“反转过”状态，供②效果发动时判断。
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
