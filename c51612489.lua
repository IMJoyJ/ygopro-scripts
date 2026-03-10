--騒動
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽回到手卡。那之后，这个效果让卡加入手卡的玩家可以从自身手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外才能发动。场上1只里侧守备表示怪兽变成表侧攻击表示。
local s,id,o=GetID()
-- 注册两个效果，分别是①效果和②效果
function s.initial_effect(c)
	-- ①：以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽回到手卡。那之后，这个效果让卡加入手卡的玩家可以从自身手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外才能发动。场上1只里侧守备表示怪兽变成表侧攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.poscon)
	-- 效果②的发动需要将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于筛选场上的里侧守备表示且能返回手牌的怪兽
function s.rthfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsAbleToHand()
end
-- 处理效果①的目标选择阶段，检查场上是否存在符合条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rthfilter(chkc) end
	-- 判断是否满足效果①的发动条件，即场上存在里侧守备表示且可返回手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽并设置为效果处理对象
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果①的处理信息，表明将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义过滤函数，用于筛选可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp,sp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,sp)
end
-- 处理效果①的发动效果，将目标怪兽送回手牌并询问是否特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在连锁中且位于场上，然后将其送回手牌
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		local sp=tc:GetControler()
		-- 获取目标玩家手中符合条件的可特殊召唤怪兽组
		local g=Duel.GetMatchingGroup(s.spfilter,sp,LOCATION_HAND,0,nil,e,tp,sp)
		-- 判断是否有符合条件的怪兽、场上是否有空位并询问玩家是否发动特殊召唤
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(sp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,sp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(sp,1,1,nil)
			-- 将玩家手牌洗切
			Duel.ShuffleHand(sp)
			-- 将选定的怪兽以里侧守备表示特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,sp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 定义效果②的发动条件，即对方怪兽攻击宣言时
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否不是自己
	return Duel.GetAttacker():GetControler()~=tp
end
-- 处理效果②的目标选择阶段，检查场上是否存在里侧守备表示且可改变表示形式的怪兽
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果②的发动条件，即场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置效果②的处理信息，表明将改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 处理效果②的发动效果，选择目标怪兽并将其变为表侧攻击表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择符合条件的怪兽作为效果②的目标
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选怪兽被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将目标怪兽变为表侧攻击表示
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
