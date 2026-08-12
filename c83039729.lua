--六武衆の師範
-- 效果：
-- ①：「六武众的师范」在自己场上只能有1只表侧表示存在。
-- ②：自己场上有「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ③：这张卡被对方的效果破坏的场合，以自己墓地1只「六武众」怪兽为对象发动。那只怪兽加入手卡。
function c83039729.initial_effect(c)
	c:SetUniqueOnField(1,0,83039729)
	-- ②：自己场上有「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c83039729.spcon)
	c:RegisterEffect(e1)
	-- ③：这张卡被对方的效果破坏的场合，以自己墓地1只「六武众」怪兽为对象发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83039729,0))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c83039729.thcon)
	e2:SetTarget(c83039729.thtg)
	e2:SetOperation(c83039729.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的「六武众」怪兽
function c83039729.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 特殊召唤规则的条件判定
function c83039729.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的「六武众」怪兽
		and	Duel.IsExistingMatchingCard(c83039729.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 判定是否被对方的效果破坏且原本由自己控制
function c83039729.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsReason(REASON_BATTLE) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤条件：墓地的「六武众」怪兽卡且可以加入手卡
function c83039729.filter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③（墓地回收）的发动准备与目标选择
function c83039729.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c83039729.filter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的「六武众」怪兽
	if chk==0 then return Duel.IsExistingTarget(c83039729.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「六武众」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83039729.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③（墓地回收）的效果处理
function c83039729.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
