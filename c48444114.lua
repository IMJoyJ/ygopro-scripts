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
-- 判断候选怪兽是否为「月光」字段怪兽且可以被当前效果特殊召唤。
function c48444114.filter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象效果：在连锁确认对象时校验对象是否在自己墓地、由自己控制且满足条件；发动时确认我方主怪兽区有空位且墓地存在至少1张满足条件的「月光」怪兽。
function c48444114.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48444114.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1张满足条件的「月光」怪兽，且能成为当前效果的对象。
		and Duel.IsExistingTarget(c48444114.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张满足条件的「月光」怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c48444114.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理将把选中的对象进行特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得取对象阶段选择的对象卡，若该卡仍与效果关联，则将其特殊召唤到己方场上。
function c48444114.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那张对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果代价检查：墓地中的这张卡可以被除外，且手牌中有至少1张可丢弃的卡才能发动。
function c48444114.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手牌中是否存在至少1张可以丢弃的卡作为代价。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地中的这张卡除外作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手牌丢弃1张卡作为发动代价（以代价+丢弃的原因处理）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 判断卡组中的卡是否为「月光」怪兽且可以加入手牌。
function c48444114.filter2(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果目标检测与操作信息：发动的条件是卡组中存在满足条件的「月光」怪兽；满足后登记操作信息为从卡组检索加入手牌。
function c48444114.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的「月光」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c48444114.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把卡组中的1张「月光」怪兽加入手牌（检索效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：提示选择、从卡组选择1张「月光」怪兽加入手牌，并向对方展示。
function c48444114.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「月光」怪兽。
	local g=Duel.SelectMatchingCard(tp,c48444114.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去其持有者的手卡（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
