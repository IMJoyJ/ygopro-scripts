--レッドポータン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「波波」怪兽为对象才能发动。那只怪兽直到下个回合的结束时当作调整使用。
-- ②：这张卡已在怪兽区域存在的状态，自己或者对方同调召唤成功的场合才能发动。从手卡·卡组把1只「波波」怪兽特殊召唤。
function c16001119.initial_effect(c)
	-- ①：以自己场上1只「波波」怪兽为对象才能发动。那只怪兽直到下个回合的结束时当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,16001119)
	e1:SetTarget(c16001119.chtg)
	e1:SetOperation(c16001119.chop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己或者对方同调召唤成功的场合才能发动。从手卡·卡组把1只「波波」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16001120)
	e2:SetCondition(c16001119.spcon)
	e2:SetTarget(c16001119.sptg)
	e2:SetOperation(c16001119.spop)
	c:RegisterEffect(e2)
end
-- 筛选可作为①对象的怪兽：必须是表侧表示的「波波」怪兽，且不是调整怪兽。
function c16001119.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x147) and not c:IsType(TYPE_TUNER)
end
-- ①的取对象处理：先确认存在合法对象，再让玩家从自己场上选择1只符合条件的「波波」怪兽作为效果对象。
function c16001119.chtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16001119.filter(chkc) end
	-- 发动时点检查：若自己场上不存在表侧表示的非调整「波波」怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c16001119.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择对象的提示信息，引导玩家选择要指定的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「波波」怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c16001119.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①的效果处理：为对象怪兽附加『直到下个回合结束时当作调整使用』的效果。
function c16001119.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡，即发动时选择的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 那只怪兽直到下个回合的结束时当作调整使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	tc:RegisterEffect(e1)
end
-- 判断条件：用于确认发生的特殊召唤是否为任意一方的同调召唤（召唤玩家为tp或1-tp）。
function c16001119.confil(c,tp)
	return (c:IsSummonPlayer(tp) or c:IsSummonPlayer(1-tp)) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选可作为②特殊召唤对象的「波波」怪兽：必须是「波波」字段且能被当前效果特殊召唤。
function c16001119.spfilter(c,e,tp)
	return c:IsSetCard(0x147) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件：存在由任意一方进行的同调召唤，且该同调召唤的怪兽不是本卡自身（保证本卡在怪兽区域已先行存在）。
function c16001119.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16001119.confil,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②发动时点检查：自己的主要怪兽区域有空位，且手卡·卡组中存在可特殊召唤的「波波」怪兽。
function c16001119.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否有空位，若无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在满足特殊召唤条件的「波波」怪兽，若不存在则不能发动。
		and Duel.IsExistingMatchingCard(c16001119.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果将进行特殊召唤，来源为手卡·卡组（具体卡片在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②的效果处理：从手卡·卡组选择1只「波波」怪兽，以表侧表示特殊召唤到自己的场上。
function c16001119.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区域有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择要特殊召唤的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选择1只符合条件的「波波」怪兽。
	local g=Duel.SelectMatchingCard(tp,c16001119.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「波波」怪兽以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
