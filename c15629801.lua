--武闘円舞
-- 效果：
-- 选择自己场上表侧表示存在的1只同调怪兽发动。把1只持有和那只怪兽相同种族·属性·等级·攻击力·守备力的「圆舞衍生物」在自己场上特殊召唤。这衍生物的战斗发生的对双方玩家的战斗伤害变成0。
function c15629801.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只同调怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15629801.target)
	e1:SetOperation(c15629801.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择怪兽的过滤条件：必须是表侧表示的同调怪兽，且当前玩家能够特殊召唤一只与它种族·属性·等级·攻击力·守备力相同的「圆舞衍生物」。
function c15629801.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
		-- 进一步确认玩家可以特殊召唤圆舞衍生物，该衍生物的种族、属性、等级、攻击力、守备力均与候选怪兽一致。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,15629802,0,TYPES_TOKEN_MONSTER,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
end
-- 发动时的取对象处理：检查对象是否合法、是否有空位与可选目标；满足条件后选择1只对象并设置特殊召唤衍生物的操作信息。
function c15629801.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15629801.filter(chkc,e,tp) end
	-- 检查自己场上是否还有空余的怪兽区，用于后续特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足条件的表侧同调怪兽可以作为取对象目标。
		and Duel.IsExistingTarget(c15629801.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示，用于选择同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上的表侧同调怪兽中选择1只作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c15629801.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次处理将产生1只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次处理将进行1次特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理时的实际动作：确认格子与对象仍合法后，创建圆舞衍生物，使其数值/信息与对象怪兽相同，特殊召唤，并赋予战斗伤害为0的效果。
function c15629801.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有空余怪兽区，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 再次确认玩家仍能特殊召唤一只与对象怪兽种族·属性·等级·攻击力·守备力相同的圆舞衍生物，若不能则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,15629802,0,TYPES_TOKEN_MONSTER,tc:GetAttack(),tc:GetDefense(),tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then return end
	-- 创建圆舞衍生物（token）。
	local token=Duel.CreateToken(tp,15629802)
	-- 持有和那只怪兽相同种族·属性·等级·攻击力·守备力（此处设置衍生物攻击力与对象怪兽相同）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(tc:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(tc:GetDefense())
	token:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetValue(tc:GetLevel())
	token:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(tc:GetRace())
	token:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetValue(tc:GetAttribute())
	token:RegisterEffect(e5)
	-- 以表侧表示将衍生物特殊召唤（特殊召唤处理的一步）。
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物的战斗发生的对双方玩家的战斗伤害变成0。
	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e6:SetValue(1)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	token:RegisterEffect(e7)
	-- 完成特殊召唤处理，结算本次特殊召唤。
	Duel.SpecialSummonComplete()
end
