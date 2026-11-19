--変容王 ヘル・ゲル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同，自己回复那只怪兽的等级×200基本分。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己主要阶段才能发动。从手卡把持有比这张卡低的等级的1只恶魔族怪兽特殊召唤。
function c85457355.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同，自己回复那只怪兽的等级×200基本分。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85457355,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,85457355)
	e1:SetTarget(c85457355.lvtg)
	e1:SetOperation(c85457355.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段才能发动。从手卡把持有比这张卡低的等级的1只恶魔族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85457355,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,85457356)
	e3:SetTarget(c85457355.sptg)
	e3:SetOperation(c85457355.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，筛选场上表侧表示、持有1星以上等级且等级与这张卡当前等级lv不同的怪兽
function c85457355.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- ①效果的Target函数，检测并选择这张卡以外场上1只满足lvfilter的怪兽作为对象，设置基本分回复操作信息
function c85457355.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c85457355.lvfilter(chkc,lv) and chkc~=e:GetHandler() end
	-- 发动条件检测时，检查双方场上是否存在除这张卡以外至少1只满足lvfilter且可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c85457355.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),lv)
		and e:GetHandler():IsLevelAbove(1) and e:GetHandler():IsRelateToEffect(e) end
	-- 向自己发送选择提示信息：“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让自己在双方怪兽区域选择除这张卡以外的1只满足lvfilter条件的怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,c85457355.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),lv)
	local rec=g:GetFirst():GetLevel()*200
	-- 设置操作信息，声明玩家tp将回复rec数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ①效果的Operation函数，将这张卡等级变为对象怪兽的等级并回复基本分，同时注册回合结束前的额外卡组同调特招限制
function c85457355.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁指定的第1张对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		-- 这张卡的等级变成和那只怪兽相同，
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 以效果使自己回复对象怪兽等级lv×200的基本分
		Duel.Recover(tp,lv*200,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c85457355.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家tp注册持续到回合结束的额外卡组特殊召唤限制效果e1
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数，禁止玩家从额外卡组特殊召唤同调怪兽以外的怪兽
function c85457355.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，筛选等级小于这张卡当前等级lv、种族为恶魔族且可特殊召唤的怪兽
function c85457355.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(lv-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的Target函数，检查怪兽区空格、这张卡等级在2星以上且手卡存在可特招的低星恶魔族怪兽，并设置特殊召唤操作信息
function c85457355.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	-- 发动条件检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查这张卡是否为2星以上且自己手卡存在至少1只满足spfilter条件可特殊召唤的恶魔族怪兽
		and e:GetHandler():IsLevelAbove(2) and Duel.IsExistingMatchingCard(c85457355.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lv) end
	-- 设置操作信息，声明将从自己手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的Operation函数，确认空格和自身等级后，从手卡选择1只比这张卡等级低的恶魔族怪兽特殊召唤
function c85457355.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己怪兽区没有可用空格则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsFaceup() and c:IsLevelAbove(2) then
		local lv=c:GetLevel()
		-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让自己在手卡中选择1只等级低于这张卡当前等级lv的恶魔族怪兽
		local g=Duel.SelectMatchingCard(tp,c85457355.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lv)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
