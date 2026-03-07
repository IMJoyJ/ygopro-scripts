--ドクターD
-- 效果：
-- ①：从自己墓地把1只「命运英雄」怪兽除外才能发动。从自己墓地选1只「命运英雄」怪兽加入手卡或特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上2只「命运英雄」怪兽为对象才能发动。作为对象的1只怪兽的攻击力变成和另1只怪兽的攻击力相同。
function c32671443.initial_effect(c)
	-- ①：从自己墓地把1只「命运英雄」怪兽除外才能发动。从自己墓地选1只「命运英雄」怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32671443,0))  --"加入手卡或特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32671443.cost)
	e1:SetTarget(c32671443.target)
	e1:SetOperation(c32671443.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上2只「命运英雄」怪兽为对象才能发动。作为对象的1只怪兽的攻击力变成和另1只怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32671443,1))  --"改变攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32671443.atktg)
	e2:SetOperation(c32671443.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查墓地是否存在1只「命运英雄」怪兽且该怪兽可以被除外作为费用，并且满足效果发动条件
function c32671443.costfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查是否满足效果发动条件：墓地存在1只「命运英雄」怪兽可以加入手卡或特殊召唤
		and Duel.IsExistingMatchingCard(c32671443.thfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 过滤函数：检查墓地是否存在1只「命运英雄」怪兽可以加入手卡或特殊召唤
function c32671443.thfilter(c,e,tp)
	if not (c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果发动时需要将墓地中的1只「命运英雄」怪兽除外作为费用
function c32671443.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果发动条件：墓地存在1只「命运英雄」怪兽且该怪兽可以被除外作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(c32671443.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的「命运英雄」怪兽作为除外费用
	local g=Duel.SelectMatchingCard(tp,c32671443.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c32671443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查是否满足效果发动条件：墓地存在1只「命运英雄」怪兽可以加入手卡或特殊召唤
		or Duel.IsExistingMatchingCard(c32671443.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
-- 效果发动时的处理函数，用于选择并处理目标卡
function c32671443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择1只满足条件的「命运英雄」怪兽进行操作
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32671443.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand()
			-- 判断是否选择将卡加入手卡：若不能特殊召唤或场上无空位或玩家选择加入手卡
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：检查场上是否存在1只「命运英雄」怪兽且该怪兽可以作为攻击力变更效果的对象
function c32671443.atkfilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc008)
		-- 检查场上是否存在1只「命运英雄」怪兽且该怪兽可以作为攻击力变更效果的对象
		and Duel.IsExistingTarget(c32671443.atkfilter2,tp,LOCATION_MZONE,0,1,c,c)
end
-- 过滤函数：检查场上是否存在1只「命运英雄」怪兽且该怪兽的攻击力与目标怪兽不同
function c32671443.atkfilter2(c,tc)
	return c:IsFaceup() and c:IsSetCard(0xc008) and not c:IsAttack(tc:GetAttack())
end
-- 过滤函数：检查场上是否存在1只「命运英雄」怪兽且该怪兽可以成为效果对象
function c32671443.tgfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xc008) and c:IsCanBeEffectTarget(e)
end
-- 过滤函数：检查选中的2只怪兽攻击力是否不同
function c32671443.gcheck(g)
	return g:GetFirst():GetAttack()~=g:GetNext():GetAttack()
end
-- 效果发动时的处理函数，用于选择并设置目标怪兽
function c32671443.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足效果发动条件：场上存在1只「命运英雄」怪兽可以作为攻击力变更效果的对象
	if chk==0 then return Duel.IsExistingTarget(c32671443.atkfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 获取场上所有「命运英雄」怪兽的集合
	local g=Duel.GetMatchingGroup(c32671443.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c32671443.gcheck,false,2,2)
	-- 设置选中的2只怪兽为效果对象
	Duel.SetTargetCard(tg)
end
-- 效果发动时的处理函数，用于执行攻击力变更效果
function c32671443.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象
	local g=Duel.GetTargetsRelateToChain()
	if g:FilterCount(Card.IsFaceup,nil)<2 then return end
	if g:GetFirst():GetAttack()==g:GetNext():GetAttack() then return end
	-- 提示玩家选择要改变攻击力的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(32671443,2))  --"请选择要改变攻击力的怪兽"
	local tc2=g:Select(tp,1,1,nil):GetFirst()
	local tc1=(g-tc2):GetFirst()
	-- 将选中的怪兽攻击力设置为另一只怪兽的攻击力
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(tc1:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc2:RegisterEffect(e1)
end
