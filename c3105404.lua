--ブリリアント・スパーク
-- 效果：
-- 「明亮火花」在1回合只能发动1张。
-- ①：自己场上的「宝石骑士」怪兽被对方怪兽的攻击或者对方的效果破坏的场合，以破坏的那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡在墓地存在的场合，把手卡1张「宝石骑士」卡送去墓地才能发动。这张卡加入手卡。
function c3105404.initial_effect(c)
	-- 「明亮火花」在1回合只能发动1张。①：自己场上的「宝石骑士」怪兽被对方怪兽的攻击或者对方的效果破坏的场合，以破坏的那1只怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
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
-- 筛选可成为①效果对象的破坏怪兽：需满足被破坏前在我方怪兽区表侧表示、属于「宝石骑士」、原本攻击力>0、能成为效果对象，且破坏后位于墓地或除外区，并符合下方破坏原因条件。
function c3105404.filter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 判断破坏原因：被对方怪兽攻击战斗破坏（攻击者由对方控制）或被对方发动的效果破坏（效果的发动者为对方）。
		and ((c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
		and c:IsSetCard(0x1047) and c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果发动时的对象选择：确认存在符合条件的目标，从被破坏的怪兽中选择1只，将其设为对象，并设置给对方造成伤害的操作信息。
function c3105404.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c3105404.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c3105404.filter,1,nil,e,tp) end
	-- 提示操作玩家选择对象，显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c3105404.filter,1,1,nil,e,tp)
	-- 将选择的怪兽登记为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 设置效果操作信息：本连锁将对对方（1-tp）造成伤害，伤害值在处理时确定，故目标暂为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理：取得对象怪兽，若其仍与本次效果关联，则给对方造成该怪兽原本攻击力数值的伤害。
function c3105404.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那张对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给予对方玩家该怪兽原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- ②效果发动代价的筛选：手卡中的「宝石骑士」卡且可作为cost送去墓地。
function c3105404.cfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToGraveAsCost()
end
-- ②效果发动代价：检查手卡是否有可丢弃的「宝石骑士」卡，若有则丢弃1张作为发动代价。
function c3105404.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：手卡中是否存在至少1张符合条件的「宝石骑士」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c3105404.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张符合条件的「宝石骑士」手卡作为发动代价。
	Duel.DiscardHand(tp,c3105404.cfilter,1,1,REASON_COST,nil)
end
-- ②效果的目标确认：确认墓地中的这张卡可以加入手卡，并设置回收操作信息。
function c3105404.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将e:GetHandler()（墓地中的这张卡）加入持有者手卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与效果关联，则将其加入持有者手卡。
function c3105404.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地中的这张卡返回持有者手卡。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
