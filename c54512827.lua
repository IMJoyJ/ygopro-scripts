--ゴーストリック・ランタン
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，对方怪兽的直接攻击宣言时或者自己场上的名字带有「鬼计」的怪兽被选择作为攻击对象时才能发动。那次攻击无效，这张卡从手卡里侧守备表示特殊召唤。
function c54512827.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c54512827.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54512827,0))  --"变成里侧表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c54512827.postg)
	e2:SetOperation(c54512827.posop)
	c:RegisterEffect(e2)
	-- 此外，对方怪兽的直接攻击宣言时……才能发动。那次攻击无效，这张卡从手卡里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54512827,1))  --"攻击无效并特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c54512827.spcon1)
	e3:SetTarget(c54512827.sptg)
	e3:SetOperation(c54512827.spop)
	c:RegisterEffect(e3)
	-- 此外，……或者自己场上的名字带有「鬼计」的怪兽被选择作为攻击对象时才能发动。那次攻击无效，这张卡从手卡里侧守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54512827,1))  --"攻击无效并特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(c54512827.spcon2)
	e4:SetTarget(c54512827.sptg)
	e4:SetOperation(c54512827.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的「鬼计」怪兽
function c54512827.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的Condition函数：判断自己场上是否存在表侧表示的「鬼计」怪兽
function c54512827.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「鬼计」怪兽，若不存在则不能召唤
	return not Duel.IsExistingMatchingCard(c54512827.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 转为里侧守备表示效果的Target函数：检查自身是否能转为里侧守备表示且本回合未发动过该效果，并注册一回合一次的Flag
function c54512827.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(54512827)==0 end
	c:RegisterFlagEffect(54512827,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：改变1张卡（自身）的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 转为里侧守备表示效果的Operation函数：若自身仍在场上且表侧表示，则将其转为里侧守备表示
function c54512827.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 手牌特殊召唤效果1（直接攻击宣言时）的Condition函数：判断是否为对方怪兽发动的直接攻击
function c54512827.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 判断攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 手牌特殊召唤效果2（被选择作为攻击对象时）的Condition函数：判断被攻击的怪兽是否为自己场上表侧表示的「鬼计」怪兽
function c54512827.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选择作为攻击对象的怪兽
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0x8d)
end
-- 手牌特殊召唤效果的Target函数：检查怪兽区域是否有空位，以及自身是否能以里侧守备表示特殊召唤
function c54512827.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置操作信息：特殊召唤1张卡（自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手牌特殊召唤效果的Operation函数：尝试无效攻击，若成功则将自身从手牌里侧守备表示特殊召唤，并向对方确认
function c54512827.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 尝试无效当前的攻击，若成功则继续处理后续效果
	if Duel.NegateAttack() then
		if not c:IsRelateToEffect(e) then return end
		-- 将自身以里侧守备表示特殊召唤到自己场上，并判断是否特殊召唤成功
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
			-- 将特殊召唤的里侧表示怪兽（自身）给对方玩家确认
			Duel.ConfirmCards(1-tp,c)
		end
	end
end
