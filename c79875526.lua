--アタッチメント・サイバーン
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：以自己场上1只龙族·机械族的「电子」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备卡使用给那只怪兽装备。
-- ②：有这张卡装备的怪兽的攻击力上升600。
-- ③：给怪兽装备的这张卡被送去墓地的场合，以这张卡以外的自己墓地1只龙族·机械族的「电子」怪兽为对象才能发动。那只怪兽特殊召唤。
function c79875526.initial_effect(c)
	-- ①：以自己场上1只龙族·机械族的「电子」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79875526,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c79875526.eqtg)
	e1:SetOperation(c79875526.eqop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽的攻击力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	c:RegisterEffect(e2)
	-- ③：给怪兽装备的这张卡被送去墓地的场合，以这张卡以外的自己墓地1只龙族·机械族的「电子」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79875526,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,79875526)
	e3:SetCondition(c79875526.spcon)
	e3:SetTarget(c79875526.sptg)
	e3:SetOperation(c79875526.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的龙族或机械族的「电子」怪兽
function c79875526.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsSetCard(0x93)
end
-- 装备效果的对象选择与发动条件判定
function c79875526.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79875526.filter(chkc) end
	-- 判定自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 判定自己场上是否存在除自身以外、满足过滤条件的怪兽作为对象
		and Duel.IsExistingTarget(c79875526.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c79875526.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备效果的执行处理
function c79875526.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中选择的第一个对象（即要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区空位、对象控制权、是否表侧表示、是否仍与效果相关，以及自身是否能唯一存在于场上
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若无法装备，则将这张卡因效果送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 从自己的手卡·场上把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c79875526.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制这张卡只能装备给作为对象的那只怪兽
function c79875526.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判定特殊召唤效果的发动条件：此卡之前在魔陷区作为装备卡，且不是因为失去装备对象而送去墓地
function c79875526.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 过滤条件：自己墓地中可以特殊召唤的龙族或机械族的「电子」怪兽
function c79875526.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsSetCard(0x93) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的对象选择与发动条件判定
function c79875526.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79875526.spfilter(chkc,e,tp) and chkc~=c end
	-- 判定自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在除自身以外、满足过滤条件的怪兽作为对象
		and Duel.IsExistingTarget(c79875526.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c79875526.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 设置连锁处理信息：包含特殊召唤分类，数量为1，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行处理
function c79875526.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的第一个对象（即要特殊召唤的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
