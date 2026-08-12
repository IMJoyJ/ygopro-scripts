--クローン複製
-- 效果：
-- ①：对方对怪兽的召唤·反转召唤成功时，以那1只怪兽为对象才能发动。把持有那只表侧表示怪兽的原本的种族·属性·等级·攻击力·守备力的1只「克隆衍生物」在自己场上特殊召唤。那只表侧表示怪兽被破坏送去墓地时这衍生物破坏。
function c86871614.initial_effect(c)
	-- ①：对方对怪兽的召唤·反转召唤成功时，以那1只怪兽为对象才能发动。把持有那只表侧表示怪兽的原本的种族·属性·等级·攻击力·守备力的1只「克隆衍生物」在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c86871614.condition)
	e1:SetTarget(c86871614.target)
	e1:SetOperation(c86871614.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 判定是否为对方玩家召唤怪兽。
function c86871614.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的可行性检测，包括检查怪兽区域空位、对象怪兽的原本等级，以及是否能特殊召唤对应数值的衍生物。
function c86871614.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:GetFirst()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:GetOriginalLevel()>0
		-- 检查玩家是否能特殊召唤具有目标怪兽原本攻击力、守备力、等级、种族、属性的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,86871615,0,TYPES_TOKEN_MONSTER,ec:GetBaseAttack(),ec:GetBaseDefense(),
			ec:GetOriginalLevel(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) end
	ec:CreateEffectRelation(e)
	-- 设置连锁处理中的操作信息：特殊召唤1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理中的操作信息：特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：验证目标怪兽是否合法、怪兽区域是否有空位，以及是否仍能特殊召唤该衍生物。
function c86871614.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if not ec:IsRelateToEffect(e) or ec:IsFacedown() then return end
	-- 检查自己场上是否已无空余的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否无法特殊召唤具有目标怪兽原本数值的衍生物。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,86871615,0,TYPES_TOKEN_MONSTER,ec:GetBaseAttack(),ec:GetBaseDefense(),
			ec:GetOriginalLevel(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) then return end
	ec:RegisterFlagEffect(86871614,RESET_EVENT+0x17a0000,0,0)
	-- 在后台创建「克隆衍生物」卡片。
	local token=Duel.CreateToken(tp,86871615)
	-- 持有那只表侧表示怪兽的原本的种族·属性·等级·攻击力·守备力
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(ec:GetBaseAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(ec:GetBaseDefense())
	token:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetValue(ec:GetOriginalLevel())
	token:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(ec:GetOriginalRace())
	token:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetValue(ec:GetOriginalAttribute())
	token:RegisterEffect(e5)
	-- 将衍生物以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 那只表侧表示怪兽被破坏送去墓地时这衍生物破坏。
	local de=Effect.CreateEffect(e:GetHandler())
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetRange(LOCATION_MZONE)
	de:SetCode(EVENT_TO_GRAVE)
	de:SetCondition(c86871614.descon)
	de:SetOperation(c86871614.desop)
	de:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(de)
end
-- 过滤出因破坏而送去墓地且带有特定标记（即被复制的目标怪兽）的卡片。
function c86871614.dfilter(c)
	return c:IsReason(REASON_DESTROY) and c:GetFlagEffect(86871614)~=0
end
-- 检查送去墓地的卡片中是否存在被复制的目标怪兽。
function c86871614.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86871614.dfilter,1,nil)
end
-- 破坏该衍生物。
function c86871614.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将该衍生物破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
