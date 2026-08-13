--聖刻龍－ネフテドラゴン
-- 效果：
-- 这张卡可以把自己场上1只名字带有「圣刻」的怪兽解放从手卡特殊召唤。1回合1次，可以把这张卡以外的自己的手卡·场上1只名字带有「圣刻」的怪兽解放，选择对方场上1只怪兽破坏。此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。
function c31516413.initial_effect(c)
	-- 这张卡可以把自己场上1只名字带有「圣刻」的怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c31516413.hspcon)
	e1:SetTarget(c31516413.hsptg)
	e1:SetOperation(c31516413.hspop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把这张卡以外的自己的手卡·场上1只名字带有「圣刻」的怪兽解放，选择对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31516413,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c31516413.descost)
	e2:SetTarget(c31516413.destg)
	e2:SetOperation(c31516413.desop)
	c:RegisterEffect(e2)
	-- 此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31516413,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(c31516413.sptg)
	e3:SetOperation(c31516413.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断候选解放怪兽是否为「圣刻」字段，解放后我方仍有怪兽区空位；且该怪兽由我方控制或为表侧表示（即若从对方场上选择则要求表侧表示）。
function c31516413.hspfilter(c,tp)
	return c:IsSetCard(0x69)
		-- 追加过滤条件：解放该怪兽后tp方仍有可用怪兽区，并且该怪兽是tp方控制或为表侧表示。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则手续的条件判定：当c为空时视为可发动；否则检查tp方场上·手卡是否存在至少1只满足hspfilter的可解放「圣刻」怪兽，作为从手卡特殊召唤的解放使用。
function c31516413.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp方是否存在至少1只可解放的「圣刻」怪兽（非上级召唤用解放，原因REASON_SPSUMMON），以决定能否以此规则特殊召唤。
	return Duel.CheckReleaseGroupEx(tp,c31516413.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则手续的目标处理：从可解放的「圣刻」怪兽中选择1只作为解放对象，若选择成功则保存到效果LabelObject并返回true。
function c31516413.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取tp方场上可作为非上级召唤用解放的卡组，并筛选出满足hspfilter的「圣刻」怪兽作为候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c31516413.hspfilter,nil,tp)
	-- 向tp方显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的处理：将之前选定的「圣刻」怪兽解放，并给特殊召唤成功的这张卡注册一个客户端提示标记，表示其出场方式为特殊召唤。
function c31516413.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤（规则召唤）为原因解放选定的怪兽，作为从手卡特殊召唤的手续。
	Duel.Release(g,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31516413,2))  --"出场方式为特殊召唤"
end
-- 破坏效果发动时的代价处理：从手卡·场上选择1只除自身以外的「圣刻」怪兽作为代价解放。
function c31516413.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认tp方手卡·场上是否存在至少1只除自身以外且满足「圣刻」字段的怪兽可以作为代价解放。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,Card.IsSetCard,1,REASON_COST,true,e:GetHandler(),0x69) end
	-- 让tp方从手卡·场上选择1只除自身以外的「圣刻」怪兽作为解放代价（非上级召唤用，原因REASON_COST）。
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsSetCard,1,1,REASON_COST,true,e:GetHandler(),0x69)
	-- 将选择的「圣刻」怪兽作为代价解放。
	Duel.Release(g,REASON_COST)
end
-- 破坏效果的目标指定：选择对方场上1只怪兽作为对象（取对象），并设置操作信息为破坏该对象。
function c31516413.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 目标检查阶段：确认对方场上存在至少1只可以作为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向tp方显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让tp方选择对方场上1只怪兽作为效果对象，并自动与当前连锁建立联系。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果会破坏1只已确定的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：取得发动时选择的对象，若该对象仍与效果相关则将其以效果原因破坏。
function c31516413.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象卡，即发动时选择要破坏的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果（REASON_EFFECT）原因为原因破坏对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：选择手卡·卡组·墓地中的龙族通常怪兽，且该怪兽能够被当前效果特殊召唤（接受召唤条件与苏生限制检查）。
function c31516413.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 必发诱发效果的发动目标设定：没有额外发动条件；设置操作信息为特殊召唤1只怪兽，具体对象在处理时选择。
function c31516413.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果包含从手卡·卡组·墓地特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 特殊召唤处理：确认怪兽区有空位后，从手卡·卡组·墓地选择1只龙族通常怪兽（墓地侧经过王家长眠之谷过滤），以表侧表示特殊召唤，并使其攻击力·守备力变成0。
function c31516413.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若tp方场上没有可用的怪兽区空位，则无法特殊召唤，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向tp方显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从tp方的手卡·卡组·墓地中检索1只满足spfilter且不受王家长眠之谷影响的龙族通常怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31516413.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽以表侧表示加入特殊召唤流程；若成功，则继续为其附加攻击力·守备力变成0的效果。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 对应效果原文“攻击力·守备力变成0特殊召唤”中的攻击力变成0部分。
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
	-- 完成所有通过SpecialSummonStep进行的特殊召唤，正式结算特殊召唤成功。
	Duel.SpecialSummonComplete()
end
