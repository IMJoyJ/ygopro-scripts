--マグネット・フィールド
-- 效果：
-- 「磁力场」的①的效果1回合只能使用1次。
-- ①：自己场上有4星以下的岩石族·地属性怪兽存在的场合，以自己墓地1只4星以下的「磁石战士」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
-- ②：1回合1次，和自己的岩石族·地属性怪兽的战斗没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽回到持有者手卡。
function c4740489.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「磁力场」的①的效果1回合只能使用1次。①：自己场上有4星以下的岩石族·地属性怪兽存在的场合，以自己墓地1只4星以下的「磁石战士」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4740489,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,4740489)
	e2:SetCondition(c4740489.spcon)
	e2:SetTarget(c4740489.sptg)
	e2:SetOperation(c4740489.spop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，和自己的岩石族·地属性怪兽的战斗没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4740489,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c4740489.atcon)
	e3:SetOperation(c4740489.atop)
	c:RegisterEffect(e3)
end
-- 定义①效果的发动条件过滤函数：检查怪兽是否为表侧表示、等级4以下、岩石族且地属性，用于确认自己场上是否存在满足条件的岩石族·地属性怪兽。
function c4740489.cfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- ①效果的发动条件：检查自己场上是否存在至少1只满足cfilter条件的岩石族·地属性4星以下表侧怪兽。
function c4740489.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 调用检索函数，在自己主要怪兽区寻找1张满足cfilter条件的表侧怪兽；存在则满足①的发动前提。
	return Duel.IsExistingMatchingCard(c4740489.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义①效果选择墓地对象的过滤函数：对象必须是卡名带有「磁石战士」的4星以下怪兽，并且能够被当前效果特殊召唤（包括满足苏生限制）。
function c4740489.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标处理函数：若在连锁确认时chkc存在，则验证该卡是否为自己墓地且满足spfilter；若在发动时chk==0，则确认有怪兽区空位且墓地存在可选目标。
function c4740489.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4740489.spfilter(chkc,e,tp) end
	-- 发动①效果时先确认自己主要怪兽区有可用的空格，保证后续特殊召唤能进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己墓地存在至少1张满足spfilter条件且能成为效果对象的「磁石战士」怪兽，以进行取对象。
		and Duel.IsExistingTarget(c4740489.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”，用于接下来的选卡操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由玩家从自己墓地选择1张满足spfilter条件的「磁石战士」怪兽作为效果对象，并将其登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c4740489.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次操作信息：将特殊召唤1张对象怪兽的信息写入连锁，供其他卡片效果（如星尘龙等）进行连锁发动或判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理时的操作函数：取得之前选择的对象怪兽，若它仍与当前效果关联，则将其特殊召唤到自己场上。
function c4740489.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果发动时选择的那1张对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（同时按正常规则检查其召唤条件和苏生限制是否满足）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：获取我方与对方正在战斗的怪兽，若我方怪兽为岩石族·地属性，且对方怪兽仍与战斗相关并在场上，则保存对方怪兽并允许发动。
function c4740489.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方操控的正在战斗的怪兽a和对方正在战斗的怪兽b；若任意一方不存在则无法发动②效果。
	local a,d=Duel.GetBattleMonster(tp)
	if not a or not d then return false end
	e:SetLabelObject(d)
	return a:IsRace(RACE_ROCK) and a:IsAttribute(ATTRIBUTE_EARTH)
		and d:IsRelateToBattle() and d:IsOnField()
end
-- ②效果处理时的操作函数：从效果中取出保存的对方怪兽，若它仍与本次战斗相关（未离场或被破坏），则将其弹回持有者手卡。
function c4740489.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 将那只对方怪兽因效果原因送回其持有者手卡，即“弹回手卡”处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
