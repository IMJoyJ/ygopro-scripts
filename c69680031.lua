--教導の騎士フルルドリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有其他的「教导」怪兽存在的场合，可以再把场上1只表侧表示怪兽的效果直到回合结束时无效。
-- ②：自己的「教导」怪兽的攻击宣言时才能发动。自己场上的全部「教导」怪兽的攻击力上升500。
function c69680031.initial_effect(c)
	-- ①：自己·对方的主要阶段，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有其他的「教导」怪兽存在的场合，可以再把场上1只表侧表示怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69680031,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,69680031)
	e1:SetCondition(c69680031.spcon)
	e1:SetTarget(c69680031.sptg)
	e1:SetOperation(c69680031.spop)
	c:RegisterEffect(e1)
	-- ②：自己的「教导」怪兽的攻击宣言时才能发动。自己场上的全部「教导」怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69680031,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,69680032)
	e2:SetCondition(c69680031.atkcon)
	e2:SetTarget(c69680031.atktg)
	e2:SetOperation(c69680031.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查怪兽是否是从额外卡组特殊召唤的
function c69680031.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：自己或对方的主要阶段，且场上存在从额外卡组特殊召唤的怪兽
function c69680031.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 检查双方场上是否存在至少1只从额外卡组特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c69680031.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果①的发动准备与合法性检测：检查自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息
function c69680031.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：检查是否为表侧表示的「教导」怪兽
function c69680031.ofilter(c)
	return c:IsFaceup() and c:IsSetCard(0x145)
end
-- 效果①的效果处理：将这张卡特殊召唤。若自己场上有其他「教导」怪兽存在，可选择将场上1只表侧表示怪兽的效果直到回合结束时无效
function c69680031.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果关联，并将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在除这张卡以外的其他表侧表示「教导」怪兽
		and Duel.IsExistingMatchingCard(c69680031.ofilter,tp,LOCATION_MZONE,0,1,c)
		-- 检查场上是否存在可以被无效化效果的表侧表示怪兽
		and Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择将场上1只表侧表示怪兽的效果无效
		and Duel.SelectYesNo(tp,aux.Stringid(69680031,2)) then  --"是否选1只怪兽效果无效？"
		-- 中断当前效果处理，使后续的无效效果与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要无效化效果的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 玩家选择场上1只可被无效化的表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		-- 为选中的怪兽显示被选择的动画效果
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 使与目标怪兽相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 可以再把场上1只表侧表示怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 可以再把场上1只表侧表示怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 效果②的发动条件：自己的「教导」怪兽进行攻击宣言时
function c69680031.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local ac=Duel.GetAttacker()
	return ac:IsFaceup() and ac:IsControler(tp) and ac:IsSetCard(0x145)
end
-- 过滤条件：检查是否为自己场上表侧表示的「教导」怪兽
function c69680031.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x145)
end
-- 效果②的发动准备与合法性检测：检查自己场上是否存在表侧表示的「教导」怪兽
function c69680031.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「教导」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69680031.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的效果处理：使自己场上的全部「教导」怪兽的攻击力上升500
function c69680031.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示的「教导」怪兽
	local g=Duel.GetMatchingGroup(c69680031.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「教导」怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
