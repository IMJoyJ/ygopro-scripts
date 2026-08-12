--ミスティック・ソードマン LV2
-- 效果：
-- 攻击里侧守备表示怪兽的场合，不进行伤害计算，那只怪兽以里侧守备表示的状态直接破坏。这张卡战斗破坏怪兽的回合的结束阶段，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「谜之剑士 LV4」
function c47507260.initial_effect(c)
	-- 攻击里侧守备表示怪兽的场合，不进行伤害计算，那只怪兽以里侧守备表示的状态直接破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c47507260.bdop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏怪兽的回合的结束阶段，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「谜之剑士 LV4」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47507260,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c47507260.descon)
	e2:SetTarget(c47507260.destg)
	e2:SetOperation(c47507260.desop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏怪兽的回合的结束阶段，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「谜之剑士 LV4」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47507260,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c47507260.spcon)
	e3:SetCost(c47507260.spcost)
	e3:SetTarget(c47507260.sptg)
	e3:SetOperation(c47507260.spop)
	c:RegisterEffect(e3)
end
c47507260.lvup={74591968}
-- 记录该卡在战斗破坏怪兽后进入结束阶段时可以发动特殊召唤效果
function c47507260.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(47507260,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为攻击方且攻击目标为里侧守备表示的怪兽
function c47507260.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击目标
	local d=Duel.GetAttackTarget()
	-- 判断是否为攻击方且攻击目标为里侧守备表示的怪兽
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 设置破坏效果的操作信息
function c47507260.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏效果的目标为攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 执行破坏操作，将攻击目标怪兽以效果原因破坏
function c47507260.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击目标
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤条件（即是否在战斗中破坏过怪兽）
function c47507260.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(47507260)>0
end
-- 支付将自身送去墓地作为特殊召唤的代价
function c47507260.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为特殊召唤的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤符合条件的「谜之剑士 LV4」卡片
function c47507260.spfilter(c,e,tp)
	return c:IsCode(74591968) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 检查是否有满足条件的「谜之剑士 LV4」可以特殊召唤
function c47507260.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌或卡组中是否存在「谜之剑士 LV4」
		and Duel.IsExistingMatchingCard(c47507260.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤操作，从手牌或卡组选择并特殊召唤「谜之剑士 LV4」
function c47507260.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「谜之剑士 LV4」卡片
	local g=Duel.SelectMatchingCard(tp,c47507260.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片以指定方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
