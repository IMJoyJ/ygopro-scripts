--神碑の牙フレーキ
-- 效果：
-- 「神碑」怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：额外怪兽区域的这张卡进行战斗的攻击宣言时才能发动。从对方卡组上面把2张卡除外。
-- ②：这张卡的战斗发生的双方的战斗伤害变成0。
-- ③：场上的这张卡被战斗·效果破坏的场合，以自己墓地1张「神碑」速攻魔法卡为对象才能发动。那张卡加入手卡。
function c47219274.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用2只可作为「神碑」融合素材的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x17f),2,true)
	-- ①：额外怪兽区域的这张卡进行战斗的攻击宣言时才能发动。从对方卡组上面把2张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47219274,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c47219274.rmcon)
	e1:SetTarget(c47219274.rmtg)
	e1:SetOperation(c47219274.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡的战斗发生的双方的战斗伤害变成0。（使对方受到的战斗伤害变为0的部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡的战斗发生的双方的战斗伤害变成0。（使自己受到的战斗伤害变为0的部分）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：场上的这张卡被战斗·效果破坏的场合，以自己墓地1张「神碑」速攻魔法卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47219274,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,47219274)
	e4:SetCondition(c47219274.thcon)
	e4:SetTarget(c47219274.thtg)
	e4:SetOperation(c47219274.thop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：这张卡在额外怪兽区域（序号>4）且作为攻击宣言的攻击怪兽或攻击对象时才能发动。
function c47219274.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是此次攻击宣言的攻击怪兽或攻击对象。
	return (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
		and c:GetSequence()>4
end
-- ①效果的目标检查与信息设置：确认对方卡组顶端2张卡能被除外，并登记从对方卡组顶端除外2张卡的操作信息。
function c47219274.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查对方卡组最上方2张卡是否都能被除外。
	if chk==0 then return Duel.GetDecktopGroup(1-tp,2):FilterCount(Card.IsAbleToRemove,nil)==2 end
	-- 登记操作信息：从对方卡组将2张卡除外，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_DECK)
end
-- ①效果的处理：将对方卡组最上方2张卡以表侧表示除外（除外原因为效果）。
function c47219274.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方卡组最上方2张卡作为要除外的对象。
	local g=Duel.GetDecktopGroup(1-tp,2)
	if #g>0 then
		-- 禁用这次从卡组取卡后的自动洗牌检查（从卡组顶端除外不应洗牌）。
		Duel.DisableShuffleCheck()
		-- 将这些卡以表侧表示从游戏中除外，除外原因为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡因战斗或效果被破坏，且破坏前在场上。
function c47219274.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择/检索条件：自己墓地中1张「神碑」速攻魔法卡且能够加入手卡。
function c47219274.thfilter(c)
	return c:IsSetCard(0x17f) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- ③效果的目标选择：从自己墓地选择1张「神碑」速攻魔法卡为对象；登记将选择的卡加入手卡的操作信息。
function c47219274.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47219274.thfilter(chkc) end
	-- 发动时检查自己墓地是否存在符合条件的「神碑」速攻魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c47219274.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择加入手卡的卡片（显示“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「神碑」速攻魔法卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c47219274.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：将选择的卡加入手卡，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果的处理：将作为对象的墓地「神碑」速攻魔法卡加入手卡。
function c47219274.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动③效果时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
