--天翔の竜騎士ガイア
-- 效果：
-- 「暗黑骑士 盖亚」怪兽＋龙族怪兽
-- ①：这张卡只要在怪兽区域存在，卡名当作「龙骑士 盖亚」使用。
-- ②：这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「螺旋枪杀」加入手卡。
-- ③：这张卡向对方怪兽攻击宣言时才能发动。那只对方怪兽的表示形式变更。
function c2519690.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用一张「暗黑骑士 盖亚」怪兽和一张龙族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xbd),aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),true)
	-- 使该卡在场上时卡名视为「龙骑士 盖亚」
	aux.EnableChangeCode(c,66889139)
	-- ②：这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「螺旋枪杀」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2519690,0))  --"选1张「螺旋枪杀」加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c2519690.thtg)
	e2:SetOperation(c2519690.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡向对方怪兽攻击宣言时才能发动。那只对方怪兽的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2519690,1))  --"对方怪兽的表示形式变更"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c2519690.postg)
	e3:SetOperation(c2519690.posop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选「螺旋枪杀」卡牌
function c2519690.thfilter(c)
	return c:IsCode(49328340) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息，确定将要从卡组或墓地检索「螺旋枪杀」并加入手牌
function c2519690.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「螺旋枪杀」卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c2519690.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡牌为「螺旋枪杀」
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 处理效果发动时的检索与加入手牌操作
function c2519690.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择一张「螺旋枪杀」卡牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2519690.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置效果发动时的处理信息，确定将要改变对方怪兽的表示形式
function c2519690.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsControler(1-tp) and d:IsCanChangePosition() end
	-- 设置连锁操作信息，指定将要处理的卡牌为对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
-- 处理效果发动时的表示形式变更操作
function c2519690.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将对方怪兽变为表侧守备表示或里侧守备表示或表侧攻击表示
		Duel.ChangePosition(d,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
