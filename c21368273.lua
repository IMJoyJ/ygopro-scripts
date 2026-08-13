--マナドゥム・トリロスークタ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以自己墓地1只2星调整为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：以自己场上的调整任意数量为对象才能发动。那些怪兽的等级变成2星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
function c21368273.initial_effect(c)
	-- 为这张卡赋予同调召唤手续：需要调整1只＋调整以外怪兽1只以上作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡同调召唤的场合，以自己墓地1只2星调整为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21368273,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,21368273)
	e1:SetCondition(c21368273.spcon)
	e1:SetTarget(c21368273.sptg)
	e1:SetOperation(c21368273.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：以自己场上的调整任意数量为对象才能发动。那些怪兽的等级变成2星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21368273,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,21368274)
	e2:SetTarget(c21368273.lvtg)
	e2:SetOperation(c21368273.lvop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡是在同调召唤成功时才能发动（即必须是同调召唤成功）。
function c21368273.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 对象筛选：选择自己墓地1只2星调整怪兽，且该怪兽可以被当前效果特殊召唤。
function c21368273.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点：检查条件并选择自己墓地1只2星调整怪兽作为对象。
function c21368273.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21368273.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区域是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地是否存在至少1只符合条件的2星调整怪兽；满足则效果可以发动。
		and Duel.IsExistingTarget(c21368273.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的提示，让玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的2星调整怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c21368273.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将当前连锁的操作信息登记为“特殊召唤1只对象怪兽”，供相关效果进行联动判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，并对那只怪兽适用效果无效化处理。
function c21368273.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象（刚才选择的2星调整怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联后，将其以表侧攻击表示特殊召唤到自己的主要怪兽区域（特殊召唤过程的一步）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤步骤，触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
-- 对象筛选：选择自己场上的表侧表示调整怪兽，且当前等级不是2星（等级为0的调整也除外）。
function c21368273.lvfilter(c)
	return c:IsType(TYPE_TUNER) and c:GetLevel()>0 and not c:IsLevel(2) and c:IsFaceup()
end
-- ②效果的目标选择：从自己场上选择任意数量（1~6只）的表侧表示调整怪兽作为对象。
function c21368273.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21368273.lvfilter(chkc) end
	-- 发动条件检查：自己场上是否存在至少1只符合条件的表侧表示调整怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21368273.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择表侧表示的卡”的提示，让玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1~6只符合条件的表侧表示调整怪兽，并全部设为效果对象。
	Duel.SelectTarget(tp,c21368273.lvfilter,tp,LOCATION_MZONE,0,1,6,nil)
end
-- 效果处理：将对象怪兽的等级变为2星，并给己方附加本回合只能从额外卡组特殊召唤同调怪兽的自肃。
function c21368273.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中仍与效果关联且表侧表示的对象怪兽群，用于后续统一变星。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的等级变成2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c21368273.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃的判定：不能从额外卡组特殊召唤不是同调怪兽的卡（即只能特殊召唤同调怪兽）。
function c21368273.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
