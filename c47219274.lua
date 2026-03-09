--神碑の牙フレーキ
-- 效果：
-- 「神碑」怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：额外怪兽区域的这张卡进行战斗的攻击宣言时才能发动。从对方卡组上面把2张卡除外。
-- ②：这张卡的战斗发生的双方的战斗伤害变成0。
-- ③：场上的这张卡被战斗·效果破坏的场合，以自己墓地1张「神碑」速攻魔法卡为对象才能发动。那张卡加入手卡。
function c47219274.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足「神碑」融合条件的怪兽作为素材进行融合召唤
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
	-- ②：这张卡的战斗发生的双方的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡的战斗发生的双方的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被战斗·效果破坏的场合，以自己墓地1张「神碑」速攻魔法卡为对象才能发动。那张卡加入手卡。
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
-- 判断是否满足效果①的发动条件：该卡为攻击怪兽或被攻击怪兽，并且位于额外怪兽区域
function c47219274.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否为攻击怪兽或被攻击怪兽
	return (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
		and c:GetSequence()>4
end
-- 设置效果①的目标和操作信息：从对方卡组最上方除外2张卡
function c47219274.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件：对方卡组最上方2张卡可以除外
	if chk==0 then return Duel.GetDecktopGroup(1-tp,2):FilterCount(Card.IsAbleToRemove,nil)==2 end
	-- 设置连锁操作信息，表示将要除外2张对方卡组最上方的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_DECK)
end
-- 执行效果①的操作：从对方卡组最上方除外2张卡
function c47219274.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方卡组最上方的2张卡
	local g=Duel.GetDecktopGroup(1-tp,2)
	if #g>0 then
		-- 禁止在除外卡时进行洗切卡组检查
		Duel.DisableShuffleCheck()
		-- 将获取到的卡组顶部2张卡以除外形式移除
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断是否满足效果③的发动条件：该卡因战斗或效果被破坏且之前在场上
function c47219274.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义过滤函数，用于筛选墓地中的「神碑」速攻魔法卡
function c47219274.thfilter(c)
	return c:IsSetCard(0x17f) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- 设置效果③的目标和操作信息：选择一张墓地中的「神碑」速攻魔法卡加入手牌
function c47219274.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47219274.thfilter(chkc) end
	-- 检查是否满足效果③的发动条件：自己墓地中存在符合条件的「神碑」速攻魔法卡
	if chk==0 then return Duel.IsExistingTarget(c47219274.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张墓地中的「神碑」速攻魔法卡作为目标
	local g=Duel.SelectTarget(tp,c47219274.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将要将一张卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果③的操作：将选定的墓地中的「神碑」速攻魔法卡加入手牌
function c47219274.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
