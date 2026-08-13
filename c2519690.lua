--天翔の竜騎士ガイア
-- 效果：
-- 「暗黑骑士 盖亚」怪兽＋龙族怪兽
-- ①：这张卡只要在怪兽区域存在，卡名当作「龙骑士 盖亚」使用。
-- ②：这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「螺旋枪杀」加入手卡。
-- ③：这张卡向对方怪兽攻击宣言时才能发动。那只对方怪兽的表示形式变更。
function c2519690.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：融合素材为「暗黑骑士 盖亚」怪兽（字段0xbd）和龙族怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xbd),aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),true)
	-- 注册①效果：这张卡在怪兽区域存在时，卡名当作「龙骑士 盖亚」（卡号66889139）使用。
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
-- 检索过滤条件：满足卡号为49328340（螺旋枪杀）且能够加入手卡。
function c2519690.thfilter(c)
	return c:IsCode(49328340) and c:IsAbleToHand()
end
-- ②效果的发动条件和目标设定：确认自己卡组·墓地存在符合条件的「螺旋枪杀」，并设置操作信息为从卡组·墓地选1张加入手卡。
function c2519690.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己卡组·墓地是否存在至少1张满足thfilter的「螺旋枪杀」（chk==0表示发动时点检查）。
	if chk==0 then return Duel.IsExistingMatchingCard(c2519690.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为不确定具体卡的从卡组·墓地选1张加入手卡（CATEGORY_TOHAND），用于配合相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- ②效果处理：从自己卡组·墓地选择1张「螺旋枪杀」加入手卡，若成功则让对方确认加入的卡。
function c2519690.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”（HINTMSG_ATOHAND），引导玩家进行检索选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选择1张满足thfilter且不受王家长眠之谷影响的「螺旋枪杀」（使用NecroValleyFilter过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c2519690.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「螺旋枪杀」以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认自己加入手卡的「螺旋枪杀」。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件和对象判定：己方怪兽攻击宣言时，确认攻击对象是对方怪兽且可以变更表示形式，然后设置操作信息为变更该怪兽的表示形式。
function c2519690.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在③效果发动判定时获取当前攻击对象怪兽。
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsControler(1-tp) and d:IsCanChangePosition() end
	-- 设置操作信息：将对攻击对象d进行表示形式变更（CATEGORY_POSITION），用于相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
-- ③效果处理：若攻击对象仍与本次战斗相关联，则变更其表示形式。
function c2519690.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 在③效果处理时再次获取当前攻击对象怪兽，以确认其状态。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将攻击对象怪兽的表示形式反转：攻击表示变为表侧守备，守备表示（表侧/里侧）变为表侧攻击。
		Duel.ChangePosition(d,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
