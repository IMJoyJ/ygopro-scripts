--聖刻龍－アセトドラゴン
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1000。1回合1次，选择场上1只龙族的通常怪兽才能发动。场上的全部名字带有「圣刻」的怪兽的等级直到结束阶段时变成和选择的怪兽相同等级。此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。
function c4022819.initial_effect(c)
	-- “这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1000。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4022819,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c4022819.ntcon)
	e1:SetOperation(c4022819.ntop)
	c:RegisterEffect(e1)
	-- “1回合1次，选择场上1只龙族的通常怪兽才能发动。场上的全部名字带有「圣刻」的怪兽的等级直到结束阶段时变成和选择的怪兽相同等级。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4022819,1))  --"等级变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c4022819.lvtg)
	e2:SetOperation(c4022819.lvop)
	c:RegisterEffect(e2)
	-- “此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4022819,2))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(c4022819.sptg)
	e3:SetOperation(c4022819.spop)
	c:RegisterEffect(e3)
end
-- 无解放召唤的适用条件判定：当c为nil时表示效果正在询问是否适用；否则要求是不解放召唤（minc==0）、等级为5以上且自己主要怪兽区有空位。
function c4022819.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足无解放召唤条件：不解放召唤（minc==0）、这张卡等级在5以上、且自己场上有空余的怪兽区域。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无解放召唤成功时的处理：给这张卡注册一个持续效果，使其原本攻击力变为1000，并在卡片离开场上等时机重置。
function c4022819.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- “这个方法召唤的这张卡的原本攻击力变成1000。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 筛选条件：场上表侧表示且为龙族的通常怪兽。
function c4022819.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON)
end
-- 对象选择处理：在发动时确认场上存在符合条件的表侧龙族通常怪兽后，提示玩家选择其中1只作为对象。
function c4022819.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4022819.lvfilter(chkc) end
	-- 发动条件确认：场上是否存在至少1张符合筛选条件、可被选择为对象的表侧龙族通常怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4022819.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示消息，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从双方场上选择1张符合条件的表侧龙族通常怪兽，并设置为该连锁的效果对象。
	Duel.SelectTarget(tp,c4022819.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 筛选“圣刻”怪兽：表侧表示且卡名属于「圣刻」字段，并拥有等级。
function c4022819.lvfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x69) and c:IsLevelAbove(0)
end
-- 等级变化效果处理：取得对象怪兽；若对象仍在场上且表侧表示，则获取场上全部表侧「圣刻」怪兽，将它们的等级统一改成对象怪兽的当前等级，直到结束阶段。
function c4022819.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 获取场上所有表侧表示的「圣刻」怪兽（排除对象本身，因为对象等级作为基准值）。
	local g=Duel.GetMatchingGroup(c4022819.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,tc)
	local lc=g:GetFirst()
	local lv=tc:GetLevel()
	while lc~=nil do
		-- “场上的全部名字带有「圣刻」的怪兽的等级直到结束阶段时变成和选择的怪兽相同等级。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
		lc=g:GetNext()
	end
end
-- 特殊召唤对象筛选：龙族通常怪兽，且能够被当前效果特殊召唤（满足苏生限制与召唤条件）。
function c4022819.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤触发效果的发动条件：无额外限制即可发动，并设置效果处理信息为从手牌·卡组·墓地特殊召唤1只怪兽。
function c4022819.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预定从手牌·卡组·墓地（0x13）特殊召唤1只怪兽，用于后续效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 特殊召唤效果处理：若自己怪兽区有空位，则从手牌·卡组·墓地选择1只符合条件的龙族通常怪兽，以表侧攻击表示特殊召唤；成功后使其攻击力、守备力变为0，最后完成特殊召唤流程。
function c4022819.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余的怪兽区域，则无法进行特殊召唤，效果处理不适用并直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手牌·卡组·墓地中，选择1只符合条件的龙族通常怪兽（并排除受王家长眠之谷影响的墓地卡）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4022819.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 以特殊召唤流程先尝试将选择的怪兽表侧攻击表示特殊召唤到自己场上；成功时继续附加攻击力·守备力变为0的效果。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- “攻击力·守备力变成0特殊召唤”（该行设置攻击力变成0的部分）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程，处理特殊召唤成功时触发的时点与相关确认。
	Duel.SpecialSummonComplete()
end
