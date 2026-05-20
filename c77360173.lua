--シンクローン・リゾネーター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场上有同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以「同调克隆共鸣者」以外的自己墓地1只「共鸣者」怪兽为对象才能发动。那只怪兽加入手卡。
function c77360173.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场上有同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,77360173+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c77360173.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以「同调克隆共鸣者」以外的自己墓地1只「共鸣者」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77360173,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c77360173.thcon)
	e2:SetTarget(c77360173.thtg)
	e2:SetOperation(c77360173.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的同调怪兽
function c77360173.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 特殊召唤规则的判定条件
function c77360173.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在表侧表示的同调怪兽
		and Duel.IsExistingMatchingCard(c77360173.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 发动条件：这张卡从场上送去墓地
function c77360173.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：自己墓地「同调克隆共鸣者」以外的「共鸣者」怪兽
function c77360173.thfilter(c)
	return c:IsSetCard(0x57) and not c:IsCode(77360173) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的对象选择与效果处理准备（Target阶段）
function c77360173.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77360173.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的「共鸣者」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c77360173.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的「共鸣者」怪兽作为对象
	local g=Duel.SelectTarget(tp,c77360173.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行（Operation阶段）
function c77360173.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
