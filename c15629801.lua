--武闘円舞
-- 效果：
-- 选择自己场上表侧表示存在的1只同调怪兽发动。把1只持有和那只怪兽相同种族·属性·等级·攻击力·守备力的「圆舞衍生物」在自己场上特殊召唤。这衍生物的战斗发生的对双方玩家的战斗伤害变成0。
function c15629801.initial_effect(c)
	-- 效果发动时创建效果，设置为自由连锁，目标为己方场上表侧表示的同调怪兽，特殊召唤衍生物，设置为取对象效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15629801.target)
	e1:SetOperation(c15629801.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的同调怪兽，且可以特殊召唤指定编号的衍生物
function c15629801.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
		-- 检查玩家是否可以特殊召唤指定参数的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,15629802,0,TYPES_TOKEN_MONSTER,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
end
-- 处理连锁判定，检查是否有满足条件的怪兽可选
function c15629801.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15629801.filter(chkc,e,tp) end
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c15629801.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c15629801.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息为召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理函数，检查是否可以特殊召唤衍生物并执行召唤
function c15629801.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 检查是否可以特殊召唤指定参数的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,15629802,0,TYPES_TOKEN_MONSTER,tc:GetAttack(),tc:GetDefense(),tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then return end
	-- 创建编号为15629802的衍生物
	local token=Duel.CreateToken(tp,15629802)
	-- 设置衍生物的攻击力为原怪兽的攻击力
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
	-- 将衍生物特殊召唤到场上
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 设置衍生物在战斗中不造成战斗伤害
	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e6:SetValue(1)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	token:RegisterEffect(e7)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
