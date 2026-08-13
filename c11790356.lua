--破戒蛮竜－バスター・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：对方场上的怪兽只要这张卡表侧表示存在变成龙族。
-- ②：自己场上没有「破坏之剑士」怪兽存在的场合，1回合1次，以自己墓地1只「破坏之剑士」为对象才能发动。那只怪兽特殊召唤。
-- ③：对方回合1次，以自己场上1只「破坏之剑士」怪兽为对象才能发动。自己墓地1只「破坏剑」怪兽当作装备卡使用给作为对象的怪兽装备。
function c11790356.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意）+1只以上的调整以外的怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方场上的怪兽只要这张卡表侧表示存在变成龙族。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(RACE_DRAGON)
	c:RegisterEffect(e1)
	-- ②：自己场上没有「破坏之剑士」怪兽存在的场合，1回合1次，以自己墓地1只「破坏之剑士」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11790356,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c11790356.spcon)
	e2:SetTarget(c11790356.sptg)
	e2:SetOperation(c11790356.spop)
	c:RegisterEffect(e2)
	-- ③：对方回合1次，以自己场上1只「破坏之剑士」怪兽为对象才能发动。自己墓地1只「破坏剑」怪兽当作装备卡使用给作为对象的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11790356,1))  --"装备"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c11790356.condition)
	e3:SetTarget(c11790356.target)
	e3:SetOperation(c11790356.operation)
	c:RegisterEffect(e3)
end
-- cfilter函数：筛选自己场上表侧表示且属于「破坏之剑士」系列（0xd7）的怪兽，用于判断场上是否存在「破坏之剑士」怪兽。
function c11790356.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd7)
end
-- spcon：②效果的发动条件：自己场上不存在表侧表示的「破坏之剑士」系怪兽时才能发动。
function c11790356.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足cfilter的怪兽，若不存在则返回true，即满足发动条件。
	return not Duel.IsExistingMatchingCard(c11790356.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- filter：筛选自己墓地中卡名为「破坏之剑士」（78193831）且能够被当前效果特殊召唤的怪兽。
function c11790356.filter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg：②效果发动时的对象选择/合法性判定。若chkc是指定对象，则校验该对象是否位于自己墓地且满足filter；若chk==0则检查场上是否有空位以及墓地是否存在合法对象。
function c11790356.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11790356.filter(chkc,e,tp) end
	-- 发动时检查自己主要怪兽区是否有空位（大于0），确保可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查自己墓地是否存在至少1张满足filter的「破坏之剑士」且能够成为效果对象。
		and Duel.IsExistingTarget(c11790356.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”，用于后续选择墓地中的特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足filter的「破坏之剑士」作为效果对象，同时登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c11790356.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，声明本效果涉及特殊召唤，对象为已确定的目标g，数量为1，供星尘龙等效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- spop：②效果处理。取得当前对象怪兽，若其仍与效果e相关（未离场/未失去联系），则将其表侧表示特殊召唤到自己场上。
function c11790356.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个效果对象，即之前选择的墓地「破坏之剑士」。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上，不检查苏生限制但检查召唤条件。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- condition：③效果的发动条件：当前回合玩家不是这张卡的控制者，即只能在对方回合发动。
function c11790356.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不等于tp（这张卡的控制者），若成立则说明现在是对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- filter2：筛选自己墓地中属于「破坏剑」系列（0xd6）的怪兽卡，且不是禁止卡，可作为装备卡使用。
function c11790356.filter2(c)
	return c:IsSetCard(0xd6) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- target：③效果发动时的目标选择/合法性判定。若chkc是指定对象则校验；若chk==0则检查魔陷区空格、自己场上对象怪兽、墓地装备卡三者是否满足条件。
function c11790356.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c11790356.cfilter(chkc) end
	-- 发动时检查自己魔陷区是否有可用空格（大于0），用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动时检查自己场上是否存在至少1张表侧表示且满足cfilter的「破坏之剑士」系怪兽可作为装备对象。
		and Duel.IsExistingTarget(c11790356.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动时检查自己墓地是否存在至少1张满足filter2的「破坏剑」怪兽可作为装备卡。
		and Duel.IsExistingMatchingCard(c11790356.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择表侧表示的卡”，用于选择自己场上的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1张表侧表示的「破坏之剑士」系怪兽作为装备对象，并登记为效果对象。
	Duel.SelectTarget(tp,c11790356.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息，声明本效果涉及墓地卡片离开墓地（装备给怪兽），类别为CATEGORY_LEAVE_GRAVE，具体对象在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- operation：③效果处理。取得对象怪兽；若魔陷区无空位、对象变为里侧或与效果失去联系则处理中止；否则从墓地选择1张「破坏剑」怪兽装备给对象，并给装备卡附加装备限制效果。
function c11790356.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个效果对象，即被选为装备对象的自己场上的「破坏之剑士」怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若自己魔陷区没有可用空格，则无法装备，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 给玩家显示选择提示，提示内容为“请选择要装备的卡”，用于选择墓地中的「破坏剑」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地选择1张满足filter2的「破坏剑」怪兽作为装备卡。
	local sg=Duel.SelectMatchingCard(tp,c11790356.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		-- 尝试将选择的「破坏剑」怪兽作为装备卡装备给对象怪兽；若装备失败则中止处理。
		if not Duel.Equip(tp,sc,tc) then return end
		-- ③：对方回合1次，以自己场上1只「破坏之剑士」怪兽为对象才能发动。自己墓地1只「破坏剑」怪兽当作装备卡使用给作为对象的怪兽装备。——这里为装备卡附加“只能装备给所选对象”的限制。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c11790356.eqlimit)
		e1:SetLabelObject(tc)
		sc:RegisterEffect(e1)
	end
end
-- eqlimit：装备限制函数，判定装备卡允许装备的对象是e的LabelObject（即当初选择的「破坏之剑士」怪兽），确保只能装备给该对象。
function c11790356.eqlimit(e,c)
	return e:GetLabelObject()==c
end
