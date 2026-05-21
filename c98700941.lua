--トリックスター・リリーベル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：这张卡可以直接攻击。
-- ③：这张卡给与对方战斗伤害时，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽加入手卡。
function c98700941.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98700941,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,98700941)
	e1:SetCondition(c98700941.spcon)
	e1:SetTarget(c98700941.sptg)
	e1:SetOperation(c98700941.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- ③：这张卡给与对方战斗伤害时，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98700941,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c98700941.thcon)
	e3:SetTarget(c98700941.thtg)
	e3:SetOperation(c98700941.thop)
	c:RegisterEffect(e3)
end
-- 判断这张卡是否是通过抽卡以外的方法加入手卡
function c98700941.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位以及自身是否可以特殊召唤
function c98700941.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的实际处理，将自身特殊召唤到场上
function c98700941.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否给与了对方玩家战斗伤害
function c98700941.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤出自己墓地中可以加入手卡的「淘气仙星」怪兽
function c98700941.thfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 回收效果的发动准备，选择自己墓地1只「淘气仙星」怪兽作为对象
function c98700941.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c98700941.thfilter(chkc) end
	-- 在发动准备阶段，检查自己墓地是否存在符合条件的「淘气仙星」怪兽
	if chk==0 then return Duel.IsExistingTarget(c98700941.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1只符合条件的「淘气仙星」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c98700941.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理的操作信息，表示此效果包含将选中的卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的实际处理，将作为对象的怪兽加入手卡
function c98700941.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将作为对象的怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
