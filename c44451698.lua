--妖精弓士イングナル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用植物族怪兽的效果特殊召唤成功的场合，以自己墓地1只6星以上的植物族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
-- ②：这张卡在特殊召唤的回合不能攻击。
function c44451698.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡用植物族怪兽的效果特殊召唤成功的场合，以自己墓地1只6星以上的植物族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44451698,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,44451698)
	e1:SetCondition(c44451698.spcon)
	e1:SetTarget(c44451698.sptg)
	e1:SetOperation(c44451698.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在特殊召唤的回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c44451698.atklimit)
	c:RegisterEffect(e2)
end
-- 判定特殊召唤信息中的类型为怪兽且种族为植物，用于确认“用植物族怪兽的效果特殊召唤成功”这一诱发条件。
function c44451698.spcon(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_PLANT~=0
end
-- 筛选自己墓地中满足条件的植物族怪兽：6星以上，且可以被此效果以表侧守备表示特殊召唤。
function c44451698.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择：确认存在空位和满足条件的墓地植物族怪兽后，选择1只为对象并登记特殊召唤的操作信息。
function c44451698.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44451698.filter(chkc,e,tp) end
	-- 检查发动合法性：自己主要怪兽区有空位，且墓地存在1只以上满足条件的植物族怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c44451698.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的植物族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c44451698.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：先给发动者附加“直到回合结束时不能特殊召唤非植物族怪兽”的自肃，再检查空位后将对象怪兽表侧守备表示特殊召唤。
function c44451698.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。②：这张卡在特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(44451698,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44451698.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家场上，使其适用。
	Duel.RegisterEffect(e1,tp)
	-- 若自己场上没有可用的主要怪兽区，则中止特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得通过此效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 自肃的过滤条件：只要不是植物族怪兽就不能被特殊召唤。
function c44451698.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_PLANT)
end
-- ②效果的处理：为这张卡自身附加“不能攻击”效果，持续到回合结束/离场等标准重置时机。
function c44451698.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡在特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
