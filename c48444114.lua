--月光香
-- 效果：
-- ①：以自己墓地1只「月光」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡除外，丢弃1张手卡才能发动。从卡组把1只「月光」怪兽加入手卡。
function c48444114.initial_effect(c)
	-- ①：以自己墓地1只「月光」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48444114,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48444114.target)
	e1:SetOperation(c48444114.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，丢弃1张手卡才能发动。从卡组把1只「月光」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48444114,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c48444114.thcost)
	e2:SetTarget(c48444114.thtg)
	e2:SetOperation(c48444114.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的怪兽是否为「月光」族且可以特殊召唤
function c48444114.filter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的target阶段，用于设置选择对象的条件
function c48444114.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48444114.filter(chkc,e,tp) end
	-- 检查玩家场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的「月光」怪兽
		and Duel.IsExistingTarget(c48444114.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c48444114.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息，将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段，执行特殊召唤操作
function c48444114.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以正面表示的方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动的cost阶段，检查是否满足除外自身和丢弃手卡的条件
function c48444114.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查玩家手牌中是否存在可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 将自身从墓地除外作为发动cost
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 丢弃1张手牌作为发动cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断卡组中的怪兽是否为「月光」族且可以加入手牌
function c48444114.filter2(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时的target阶段，设置检索目标
function c48444114.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在满足条件的「月光」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48444114.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段，执行检索并加入手牌操作
function c48444114.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的怪兽作为效果对象
	local g=Duel.SelectMatchingCard(tp,c48444114.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认翻开的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
