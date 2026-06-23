--ブリリアント・スパーク
-- 效果：
-- 「明亮火花」在1回合只能发动1张。
-- ①：自己场上的「宝石骑士」怪兽被对方怪兽的攻击或者对方的效果破坏的场合，以破坏的那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡在墓地存在的场合，把手卡1张「宝石骑士」卡送去墓地才能发动。这张卡加入手卡。
function c3105404.initial_effect(c)
	-- ①：自己场上的「宝石骑士」怪兽被对方怪兽的攻击或者对方的效果破坏的场合，以破坏的那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,3105404+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3105404.target)
	e1:SetOperation(c3105404.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把手卡1张「宝石骑士」卡送去墓地才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCost(c3105404.thcost)
	e2:SetTarget(c3105404.thtg)
	e2:SetOperation(c3105404.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断被破坏的怪兽是否满足效果发动条件，包括位置、控制权、破坏原因、种族、攻击力和是否能成为效果对象。
function c3105404.filter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 判断破坏原因是否为对方效果或对方攻击，确保是对方造成的破坏。
		and ((c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
		and c:IsSetCard(0x1047) and c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 设置效果的目标，选择满足条件的被破坏怪兽作为对象。
function c3105404.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c3105404.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c3105404.filter,1,nil,e,tp) end
	-- 向玩家提示“请选择效果的对象”，用于选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c3105404.filter,1,1,nil,e,tp)
	-- 将筛选出的怪兽设置为效果对象。
	Duel.SetTargetCard(g)
	-- 设置效果处理时的伤害信息，准备对对方造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 处理效果的发动，对目标怪兽造成其攻击力数值的伤害。
function c3105404.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以目标怪兽的攻击力为数值，对对方造成伤害。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 过滤函数，用于判断手牌中是否存在可作为代价的「宝石骑士」卡。
function c3105404.cfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToGraveAsCost()
end
-- 处理效果的发动，丢弃手牌中的一张「宝石骑士」卡作为代价。
function c3105404.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少一张「宝石骑士」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c3105404.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃一张「宝石骑士」卡作为发动代价。
	Duel.DiscardHand(tp,c3105404.cfilter,1,1,REASON_COST,nil)
end
-- 设置效果的目标，准备将此卡加入手牌。
function c3105404.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理时的回手信息，准备将此卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，将此卡加入手牌。
function c3105404.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以效果原因加入手牌。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
