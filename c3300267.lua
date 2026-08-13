--聖刻龍－シユウドラゴン
-- 效果：
-- ①：这张卡可以把自己场上1只「圣刻」怪兽解放从手卡特殊召唤。
-- ②：1回合1次，把这张卡以外的自己的手卡·场上1只「圣刻」怪兽解放，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。
-- ③：这张卡被解放的场合发动。从自己的手卡·卡组·墓地选1只龙族通常怪兽，攻击力·守备力变成0特殊召唤。
function c3300267.initial_effect(c)
	-- ①：这张卡可以把自己场上1只「圣刻」怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c3300267.hspcon)
	e1:SetTarget(c3300267.hsptg)
	e1:SetOperation(c3300267.hspop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡以外的自己的手卡·场上1只「圣刻」怪兽解放，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3300267,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c3300267.descost)
	e2:SetTarget(c3300267.destg)
	e2:SetOperation(c3300267.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被解放的场合发动。从自己的手卡·卡组·墓地选1只龙族通常怪兽，攻击力·守备力变成0特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3300267,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(c3300267.sptg)
	e3:SetOperation(c3300267.spop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤手续的解放素材过滤条件：要求是「圣刻」怪兽，且解放后自己仍有可用怪兽区，并且该卡是自己控制的或是表侧表示。
function c3300267.hspfilter(c,tp)
	return c:IsSetCard(0x69)
		-- 进一步检查解放该卡后自己场上仍有怪兽区空格，并且该卡是自己控制或表侧表示（即满足可解放条件）。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤手续的进入条件：对于非询问场合，检查当前玩家场上是否存在至少1只满足hspfilter的「圣刻」怪兽可供解放；若c为nil（规则询问）则直接允许。
function c3300267.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 调用Duel.CheckReleaseGroupEx，确认场上存在至少1只满足hspfilter的「圣刻」怪兽可作为特殊召唤的解放素材。
	return Duel.CheckReleaseGroupEx(tp,c3300267.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤手续的目标处理：取得所有可解放的「圣刻」怪兽，提示玩家选择1只，并将选中卡暂存至效果的LabelObject；未选择则返回false。
function c3300267.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家tp所有可解放的卡片组（场上，不含手卡），并筛选出满足hspfilter的「圣刻」怪兽作为候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c3300267.hspfilter,nil,tp)
	-- 弹出选择提示，要求玩家选择要解放的「圣刻」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的操作处理：拿出之前选择的「圣刻」怪兽将其解放，并给成功特殊召唤的这张卡注册一个标志，表示其以特殊召唤方式出场。
function c3300267.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「圣刻」怪兽解放，解放原因是特殊召唤手续（REASON_SPSUMMON）。
	Duel.Release(g,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(3300267,2))  --"出场方式为特殊召唤"
end
-- ②效果的发动代价：确认并选择从手卡·场上解放1只「圣刻」怪兽（除自身外），将其解放作为发动代价。
function c3300267.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认存在至少1只可解放的「圣刻」怪兽（除自身外，手卡·场上皆可）用于支付发动代价。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,Card.IsSetCard,1,REASON_COST,true,e:GetHandler(),0x69) end
	-- 从手卡·场上选择1只「圣刻」怪兽（除自身外）作为代价解放素材。
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsSetCard,1,1,REASON_COST,true,e:GetHandler(),0x69)
	-- 将选择的「圣刻」怪兽解放，原因标记为代价（REASON_COST），因此该解放不受“不能解放”等效果影响。
	Duel.Release(g,REASON_COST)
end
-- ②效果的取对象过滤条件：对方场上的魔法·陷阱卡（魔法或陷阱类型）。
function c3300267.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果的发动目标处理：若指定对象则检查其是否为对方场上魔陷；发动时确认存在至少1张合法对象，选择1张作为效果对象，并设置破坏操作信息。
function c3300267.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c3300267.desfilter(chkc) end
	-- 发动条件检查：确认对方场上存在至少1张魔法·陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c3300267.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，要求玩家选择要破坏的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法·陷阱卡作为效果对象，并设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c3300267.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本连锁将破坏1张卡（目标为g）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的解决处理：取得效果对象，若该对象仍与效果关联，则将其破坏。
function c3300267.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象（因为只有一个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡破坏，破坏原因标记为效果（REASON_EFFECT）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果特殊召唤的过滤条件：龙族通常怪兽，且能够被玩家tp以效果特殊召唤（需要满足召唤条件与苏生限制）。
function c3300267.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③诱发效果的目标设置：必发效果，发动时总是可用；同时设置操作信息，表示将从手卡·卡组·墓地特殊召唤1只怪兽。
function c3300267.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁包含特殊召唤，数量为1，来源为玩家tp的手卡·卡组·墓地（0x13）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- ③效果的解决处理：若有怪兽区空位，则从手卡·卡组·墓地选择1只符合条件的龙族通常怪兽特殊召唤，并附加攻击力·守备力变为0的效果。
function c3300267.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有主要怪兽区空位，若无则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的龙族通常怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地（0x13）中，通过不受王家长眠之谷影响的过滤条件选择1只龙族通常怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3300267.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 以表侧表示将选中的怪兽特殊召唤（分解步骤），并在成功后对其设置攻击力变为0的效果。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 攻击力·守备力变成0
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
	-- 特殊召唤分解步骤完成，正式结束特殊召唤处理并触发召唤成功的相关时点。
	Duel.SpecialSummonComplete()
end
