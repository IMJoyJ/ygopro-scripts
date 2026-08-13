--妖仙獣 凶旋嵐
-- 效果：
-- ①：这张卡召唤成功的场合才能发动。从卡组把「妖仙兽 凶旋岚」以外的1只「妖仙兽」怪兽特殊召唤。
-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c49249907.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从卡组把「妖仙兽 凶旋岚」以外的1只「妖仙兽」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c49249907.sptg)
	e1:SetOperation(c49249907.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c49249907.retcon)
	e2:SetTarget(c49249907.rettg)
	e2:SetOperation(c49249907.retop)
	c:RegisterEffect(e2)
	if not c49249907.global_check then
		c49249907.global_check=true
		-- ①：这张卡召唤成功的场合才能发动。从卡组把「妖仙兽 凶旋岚」以外的1只「妖仙兽」怪兽特殊召唤。②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(49249907)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局辅助效果的操作为aux.sumreg，用于在每次特殊召唤成功时登记该卡“本回合被特殊召唤”的标记，供②的“特殊召唤的回合”判定使用。
		ge1:SetOperation(aux.sumreg)
		-- 将全局效果ge1注册到全场（双方玩家），使其持续监视特殊召唤成功事件；0表示不限定玩家。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义①效果可特殊召唤的卡组的筛选条件：卡名属于“妖仙兽”字段、不是「妖仙兽 凶旋岚」自身、且可以被玩家tp用效果以表侧表示特殊召唤。
function c49249907.filter(c,e,tp)
	return c:IsSetCard(0xb3) and not c:IsCode(49249907) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与目标设定：仅在己方主要怪兽区有空位且卡组存在符合条件的「妖仙兽」怪兽时才能发动。
function c49249907.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认己方主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动合法性检查时，确认卡组中存在至少1张符合条件的「妖仙兽」怪兽（且不包含自身），以满足特殊召唤条件。
		and Duel.IsExistingMatchingCard(c49249907.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次操作的信息：效果处理时将进行1次从卡组的特殊召唤，便于其他卡进行联动/检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：若场上仍有空位，则从卡组选择1只符合条件的「妖仙兽」怪兽，以表侧表示特殊召唤到己方场上。
function c49249907.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中筛选并选择1张满足filter条件的「妖仙兽」怪兽，作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c49249907.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到己方场上（sumtype为0，且不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡持有“特殊召唤的回合”标记（即在本回合被特殊召唤过），结束阶段才可发动。
function c49249907.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(49249907)~=0
end
-- ②效果的发动目标：无选择目标，只在操作信息中登记要将此卡返回持有者手卡。
function c49249907.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记操作信息：效果处理时将这张卡返回持有者手卡，分类为“返回手卡”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：若此卡仍与效果关联（未被离场或无效），则将其返回持有者手卡。
function c49249907.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果为原因，将这张卡送回持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
