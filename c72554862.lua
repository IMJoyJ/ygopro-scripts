--ウォークライ・スキーラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升对方场上的怪兽数量×100。
-- ②：自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段，以自己墓地1只5星以下的战士族怪兽为对象才能发动。那只怪兽特殊召唤。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，自己不能用5星以下的怪兽直接攻击。
function c72554862.initial_effect(c)
	-- ①：这张卡的攻击力上升对方场上的怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c72554862.val)
	c:RegisterEffect(e1)
	-- ②：自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段，以自己墓地1只5星以下的战士族怪兽为对象才能发动。那只怪兽特殊召唤。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，自己不能用5星以下的怪兽直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72554862,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,72554862)
	e2:SetCondition(c72554862.spcon)
	e2:SetTarget(c72554862.sptg)
	e2:SetOperation(c72554862.spop)
	c:RegisterEffect(e2)
	if not c72554862.global_check then
		c72554862.global_check=true
		-- 自己的战士族·地属性怪兽进行过战斗
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_CONFIRM)
		ge1:SetOperation(c72554862.checkop)
		-- 注册全局效果，用于在决斗中记录玩家是否有战士族·地属性怪兽进行过战斗
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查怪兽是否为战士族·地属性
function c72554862.check(c)
	return c and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 在战斗确认时，若有战士族·地属性怪兽进行战斗，则为对应玩家注册已战斗过的标记
function c72554862.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上处于战斗中的怪兽
	local c0,c1=Duel.GetBattleMonster(0)
	if c72554862.check(c0) then
		-- 为先攻玩家注册已进行过战斗的标记，持续到回合结束
		Duel.RegisterFlagEffect(0,72554862,RESET_PHASE+PHASE_END,0,1)
	end
	if c72554862.check(c1) then
		-- 为后攻玩家注册已进行过战斗的标记，持续到回合结束
		Duel.RegisterFlagEffect(1,72554862,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 计算攻击力上升数值的辅助函数
function c72554862.val(e,c)
	-- 返回对方场上的怪兽数量×100的数值
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*100
end
-- 效果②的发动条件判定函数
function c72554862.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家本回合是否有战士族·地属性怪兽进行过战斗
	return Duel.GetFlagEffect(tp,72554862)>0
		-- 判定当前是否为战斗阶段，且不在伤害计算后
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤墓地中满足5星以下、战士族且可以特殊召唤的怪兽
function c72554862.spfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与目标选择函数
function c72554862.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72554862.spfilter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c72554862.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72554862.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤场上表侧表示的「战吼」怪兽
function c72554862.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- 效果②的处理函数
function c72554862.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 获取自己场上所有表侧表示的「战吼」怪兽
	local g=Duel.GetMatchingGroup(c72554862.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历所有符合条件的「战吼」怪兽
	for tc in aux.Next(g) do
		-- 自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(200)
		tc:RegisterEffect(e1)
	end
	-- 这个回合，自己不能用5星以下的怪兽直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置不能直接攻击的效果影响对象为5星以下的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLevelBelow,5))
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该回合内不能直接攻击的限制效果
	Duel.RegisterEffect(e2,tp)
end
