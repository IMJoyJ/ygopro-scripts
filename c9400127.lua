--溟界の漠－フロギ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从场上送去墓地的场合或者从墓地的特殊召唤成功的场合，以对方场上1只表侧表示怪兽和持有那只怪兽的攻击力以上的攻击力的对方墓地1只怪兽为对象才能发动。作为对象的墓地的怪兽在对方场上特殊召唤，作为对象的对方场上的怪兽送去墓地。
-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡加入手卡。
function c9400127.initial_effect(c)
	-- ①：这张卡从场上送去墓地的场合或者从墓地的特殊召唤成功的场合，以对方场上1只表侧表示怪兽和持有那只怪兽的攻击力以上的攻击力的对方墓地1只怪兽为对象才能发动。作为对象的墓地的怪兽在对方场上特殊召唤，作为对象的对方场上的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9400127,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,9400127)
	e1:SetCondition(c9400127.spcon)
	e1:SetTarget(c9400127.sptg)
	e1:SetOperation(c9400127.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c9400127.spcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9400127,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,9400128)
	e3:SetCost(c9400127.thcost)
	e3:SetTarget(c9400127.thtg)
	e3:SetOperation(c9400127.thop)
	c:RegisterEffect(e3)
end
-- 判定这张卡是否是从场上送去墓地
function c9400127.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判定这张卡是否是从墓地特殊召唤成功
function c9400127.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤对方场上表侧表示怪兽：要求对方墓地存在持有该怪兽攻击力以上的攻击力且能特殊召唤的怪兽
function c9400127.tgfilter(c,e,tp)
	-- 该怪兽必须表侧表示，且对方墓地存在攻击力在其之上并能特殊召唤的怪兽
	return c:IsFaceup() and Duel.IsExistingTarget(c9400127.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,c:GetAttack())
end
-- 过滤对方墓地怪兽：攻击力在指定数值以上，且能特殊召唤到对方场上
function c9400127.spfilter(c,e,tp,atk)
	return c:IsAttackAbove(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果①的靶向判定与对象选择
function c9400127.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在chk==0时，确认对方场上有可用于特殊召唤的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 且对方场上存在满足条件的表侧表示怪兽
		and Duel.IsExistingTarget(c9400127.tgfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只表侧表示怪兽作为对象
	local g1=Duel.SelectTarget(tp,c9400127.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只持有该怪兽攻击力以上攻击力的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c9400127.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,g1:GetFirst():GetAttack())
	-- 设置特殊召唤的操作信息，包含选中的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	-- 设置送去墓地的操作信息，包含选中的场上怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
end
-- 效果①的处理：特殊召唤墓地怪兽，并将场上怪兽送去墓地
function c9400127.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	-- 若作为对象的墓地怪兽仍适应效果，则将其在对方场上表侧表示特殊召唤
	if lc:IsRelateToEffect(e) and Duel.SpecialSummon(lc,0,tp,1-tp,false,false,POS_FACEUP)~=0
		and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将作为对象的对方场上怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 效果②的发动代价：将1张手卡送去墓地
function c9400127.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，确认手卡中是否存在可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手卡中1张可以作为代价送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的靶向判定：确认此卡是否能加入手卡并设置操作信息
function c9400127.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置加入手卡的操作信息，包含此卡自身
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果②的处理：将墓地的此卡加入手卡
function c9400127.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
