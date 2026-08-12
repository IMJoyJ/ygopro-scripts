--物理分身
-- 效果：
-- 对方回合才能发动。把1只持有和指定的对方怪兽相同等级·种族·属性·攻击力·守备力的「幻觉衍生物」特殊召唤。回合结束时这只衍生物破坏。
function c63442604.initial_effect(c)
	-- 对方回合才能发动。把1只持有和指定的对方怪兽相同等级·种族·属性·攻击力·守备力的「幻觉衍生物」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c63442604.condition)
	e1:SetTarget(c63442604.target)
	e1:SetOperation(c63442604.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：当前回合玩家不是自己（即对方回合）
function c63442604.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不是自己
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：场上表侧表示、等级大于0，且可以特殊召唤对应数值衍生物的怪兽
function c63442604.cfilter(c,tp)
	return c:IsFaceup() and c:GetLevel()>0
		-- 检查玩家是否能特殊召唤具有该怪兽相同攻击力、守备力、等级、种族、属性的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,63442605,0,TYPES_TOKEN_MONSTER,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
end
-- 定义效果发动的目标选择与合法性检查
function c63442604.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c63442604.cfilter(chkc,tp) end
	-- 在发动时，检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 在发动时，检查对方场上是否存在满足条件的怪兽作为对象
		Duel.IsExistingTarget(c63442604.cfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只满足条件的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c63442604.cfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：包含产生衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：包含特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义效果处理：获取对象怪兽，并检查怪兽区域空位及特招合法性
function c63442604.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 检查自身怪兽区域是否已无空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或者检查是否无法特殊召唤对应数值的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,63442605,0,TYPES_TOKEN_MONSTER,tc:GetAttack(),tc:GetDefense(),
			tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then return end
	-- 在系统后台创建「幻觉衍生物」的卡片数据
	local token=Duel.CreateToken(tp,63442605)
	-- 持有和指定的对方怪兽相同等级·种族·属性·攻击力·守备力的「幻觉衍生物」
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
	-- 将衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 回合结束时这只衍生物破坏。
	local de=Effect.CreateEffect(e:GetHandler())
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetRange(LOCATION_MZONE)
	de:SetCode(EVENT_PHASE+PHASE_END)
	de:SetCountLimit(1)
	de:SetOperation(c63442604.desop)
	de:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(de)
end
-- 定义衍生物在回合结束时破坏的具体处理
function c63442604.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏该衍生物自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
