--翠嵐の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
-- ②：这张卡和相同纵列的对方怪兽进行战斗的攻击宣言时，以自己墓地1只「机界骑士」怪兽为对象才能发动。那只怪兽加入手卡。
function c66022706.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,66022706+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c66022706.hspcon)
	e1:SetValue(c66022706.hspval)
	c:RegisterEffect(e1)
	-- ②：这张卡和相同纵列的对方怪兽进行战斗的攻击宣言时，以自己墓地1只「机界骑士」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66022706,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c66022706.thcon)
	e2:SetTarget(c66022706.thtg)
	e2:SetOperation(c66022706.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片所在的纵列是否存在其他卡（即该纵列有2张以上的卡存在）
function c66022706.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 特殊召唤规则的Condition函数：判断自己场上是否存在符合特殊召唤条件的可用怪兽区域
function c66022706.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取双方场上所有处于“相同纵列有2张以上卡存在”的卡片组
	local lg=Duel.GetMatchingGroup(c66022706.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡片
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 判断在这些卡片所在的纵列中，自己场上是否有可用的主要怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的Value函数：计算并返回允许特殊召唤的区域（zone）
function c66022706.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取双方场上所有处于“相同纵列有2张以上卡存在”的卡片组
	local lg=Duel.GetMatchingGroup(c66022706.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡片
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 效果②发动的Condition函数：判断是否为自身与相同纵列的对方怪兽进行战斗的攻击宣言时
function c66022706.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	-- 验证进行战斗的双方中有一方是自身，且对方怪兽存在于自身的相同纵列中
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and tc and c:GetColumnGroup():IsContains(tc)
end
-- 过滤函数：检索自己墓地中可以加入手牌的「机界骑士」怪兽
function c66022706.thfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②发动的Target函数：进行效果发动的合法性检测，并选择墓地的「机界骑士」怪兽作为对象
function c66022706.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66022706.thfilter(chkc) end
	-- 在发动效果的准备阶段，检查自己墓地是否存在至少1只满足条件的「机界骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c66022706.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「机界骑士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66022706.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②发动的Operation函数：执行将对象怪兽加入手牌的效果处理
function c66022706.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
