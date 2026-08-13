--竜騎士ブラック・マジシャン・ガール
-- 效果：
-- 「黑魔术少女」＋龙族怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤以及用「蒂迈欧之眼」的效果才能特殊召唤。
-- ①：自己·对方回合1次，把1张手卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
function c43892408.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「黑魔术少女」（卡号38033121）和1只龙族怪兽作为融合素材进行融合召唤，对应效果原文中「黑魔术少女」＋龙族怪兽的融合素材记述。
	aux.AddFusionProcCodeFun(c,38033121,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤以及用「蒂迈欧之眼」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c43892408.splimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合1次，把1张手卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43892408,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c43892408.cost)
	e2:SetTarget(c43892408.target)
	e2:SetOperation(c43892408.activate)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件判定：只有以融合召唤方式特殊召唤，或由「蒂迈欧之眼」（卡号1784686）的效果特殊召唤时，才允许这张卡特殊召唤，从而限制召唤方式。
function c43892408.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or se:GetHandler():IsCode(1784686)
end
-- 效果的发动代价处理：从手卡丢弃1张卡作为代价，对应①效果中的“把1张手卡送去墓地”。
function c43892408.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中是否存在1张以上可以作为代价送去墓地的卡，若无则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：由玩家从手卡选择1张卡，以代价（REASON_COST）丢弃（送去墓地）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 筛选条件：选择场上的表侧表示卡作为效果对象。
function c43892408.filter(c)
	return c:IsFaceup()
end
-- 发动时选择对象并登记操作信息：将场上1张表侧表示卡作为效果对象，并通知系统该效果将进行破坏处理。
function c43892408.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c43892408.filter(chkc) end
	-- 对象合法性检查：确认场上是否存在1张表侧表示卡可以作为这张卡的效果对象，若无则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c43892408.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示消息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上的表侧表示卡中选择1张作为效果对象，并自动将该卡登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c43892408.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：宣告这个效果将破坏1张卡，用于连锁处理中的状态检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得发动时选择的对象卡，若该卡仍与此效果关联且为表侧表示，则将其破坏。
function c43892408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象卡（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因（REASON_EFFECT）破坏对象卡，对应“那张表侧表示卡破坏”。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
