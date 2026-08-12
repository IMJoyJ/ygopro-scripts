--ドラグニティナイト－トライデント
-- 效果：
-- 龙族调整＋调整以外的鸟兽族怪兽1只以上
-- ①：1回合1次，把自己场上最多3张卡送去墓地才能发动。把对方的额外卡组确认，选为这个效果发动而送去墓地的数量的卡送去墓地。
function c80159717.initial_effect(c)
	-- 添加同调召唤手续：龙族调整＋调整以外的鸟兽族怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，把自己场上最多3张卡送去墓地才能发动。把对方的额外卡组确认，选为这个效果发动而送去墓地的数量的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80159717,0))  --"确认额外卡组"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c80159717.excost)
	e1:SetOperation(c80159717.exop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：把自己场上最多3张卡送去墓地
function c80159717.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方额外卡组的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	if ct>3 then ct=3 end
	-- 检查发动条件：对方额外卡组有卡，且自己场上存在至少1张可以作为代价送去墓地的卡
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张以上、最多为对方额外卡组数量（且不超过3张）的可以作为代价送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 定义效果处理：确认对方额外卡组，并选择对应数量的卡送去墓地
function c80159717.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	local ct=e:GetLabel()
	if g:GetCount()<ct then return end
	-- 给发动效果的玩家确认对方额外卡组的卡片
	Duel.ConfirmCards(tp,g,true)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从对方额外卡组中选择与送去墓地的代价卡数量相同的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,ct,ct,nil)
	-- 将选中的对方额外卡组的卡送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 洗切对方的额外卡组
	Duel.ShuffleExtra(1-tp)
end
