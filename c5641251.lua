--F.A.デッド・ヒート
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方怪兽的直接攻击宣言时才能发动。从卡组把1只「方程式运动员」怪兽特殊召唤。
-- ②：自己的「方程式运动员」怪兽和对方怪兽进行战斗的伤害计算前才能发动1次。双方各掷1次骰子。自己的出现数目比对方大的场合，那只进行战斗的自己怪兽的等级直到回合结束时上升4星。自己的出现数目比对方小的场合，那只自己怪兽破坏。出现的数目相同的场合，重掷骰子。
function c5641251.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方怪兽的直接攻击宣言时才能发动。从卡组把1只「方程式运动员」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5641251,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,5641251)
	e2:SetCondition(c5641251.spcon)
	e2:SetTarget(c5641251.sptg)
	e2:SetOperation(c5641251.spop)
	c:RegisterEffect(e2)
	-- ②：自己的「方程式运动员」怪兽和对方怪兽进行战斗的伤害计算前才能发动1次。双方各掷1次骰子。自己的出现数目比对方大的场合，那只进行战斗的自己怪兽的等级直到回合结束时上升4星。自己的出现数目比对方小的场合，那只自己怪兽破坏。出现的数目相同的场合，重掷骰子。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5641251,1))
	e3:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c5641251.lvlcon)
	e3:SetOperation(c5641251.lvlop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件函数（对方怪兽直接攻击宣言时）
function c5641251.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由对方控制，且没有攻击对象（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤卡组中可以特殊召唤的「方程式运动员」怪兽的过滤条件函数
function c5641251.spfilter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①号效果的发动准备与合法性检测函数
function c5641251.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「方程式运动员」怪兽
		and Duel.IsExistingMatchingCard(c5641251.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理函数（从卡组特殊召唤1只「方程式运动员」怪兽）
function c5641251.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「方程式运动员」怪兽
	local g=Duel.SelectMatchingCard(tp,c5641251.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动条件函数（自己的「方程式运动员」怪兽和对方怪兽进行战斗的伤害计算前）
function c5641251.lvlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取当前进行战斗的被攻击怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc,tc=tc,bc end
	return bc:IsFaceup() and tc:IsFaceup() and tc:IsSetCard(0x107)
end
-- ②号效果的实际处理函数（双方掷骰子并根据结果改变等级或破坏怪兽）
function c5641251.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，获取当前进行战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 效果处理时，获取当前进行战斗的被攻击怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc,tc=tc,bc end
	local d1=0
	local d2=0
	while d1==d2 do
		-- 双方玩家各掷1次骰子，并获取两者的点数
		d1,d2=Duel.TossDice(tp,1,1)
	end
	if d1>d2 then
		-- 那只进行战斗的自己怪兽的等级直到回合结束时上升4星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(4)
		tc:RegisterEffect(e1)
	else
		-- 因效果将那只进行战斗的自己怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
