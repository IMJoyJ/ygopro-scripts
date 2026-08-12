--デストーイ・サンクチュアリ
-- 效果：
-- 丢弃1张手卡，从自己的额外卡组把2只「魔玩具」怪兽送去墓地才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的全部融合怪兽也当作「魔玩具」怪兽使用。
-- ②：这张卡被送去墓地的场合，以自己墓地1只「魔玩具」融合怪兽为对象才能发动。那只怪兽回到额外卡组。
function c74839123.initial_effect(c)
	-- 丢弃1张手卡，从自己的额外卡组把2只「魔玩具」怪兽送去墓地才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c74839123.cost)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的全部融合怪兽也当作「魔玩具」怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为融合怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FUSION))
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetValue(0xad)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以自己墓地1只「魔玩具」融合怪兽为对象才能发动。那只怪兽回到额外卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c74839123.tdtg)
	e3:SetOperation(c74839123.tdop)
	c:RegisterEffect(e3)
end
-- 过滤条件：额外卡组的「魔玩具」怪兽且能作为代价送去墓地
function c74839123.cfilter(c)
	return c:IsSetCard(0xad) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价：检查手牌中是否存在可丢弃的卡，以及额外卡组是否存在至少2只满足条件的「魔玩具」怪兽
function c74839123.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡（排除这张卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 并且检查额外卡组是否存在至少2只满足条件的「魔玩具」怪兽
		and Duel.IsExistingMatchingCard(c74839123.cfilter,tp,LOCATION_EXTRA,0,2,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 给玩家发送“选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组选择2只满足条件的「魔玩具」怪兽
	local g=Duel.SelectMatchingCard(tp,c74839123.cfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：墓地的「魔玩具」融合怪兽且能回到额外卡组
function c74839123.filter(c)
	return c:IsSetCard(0xad) and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
-- 效果②的发动准备：进行对象合法性检查，并让玩家选择墓地中的1只「魔玩具」融合怪兽作为对象，设置操作信息
function c74839123.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74839123.filter(chkc) end
	-- 检查墓地中是否存在至少1只满足条件的「魔玩具」融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c74839123.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送“选择要返回卡组的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择墓地中的1只「魔玩具」融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74839123.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为：将选中的1张卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 效果②的效果处理：获取选中的对象，若其仍符合条件，则将其送回额外卡组
function c74839123.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回额外卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
