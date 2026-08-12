--SPYRAL RESORT
-- 效果：
-- 这张卡的控制者在每次自己结束阶段让自己墓地1只怪兽回到卡组。或者不回到卡组让这张卡破坏。
-- ①：只要这张卡在场地区域存在，这张卡以外的自己场上的「秘旋谍」卡不会成为对方的效果的对象。
-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「秘旋谍」怪兽加入手卡。
function c54631665.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，这张卡以外的自己场上的「秘旋谍」卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c54631665.tgtg)
	-- 设置不能成为对方卡的效果的对象（由对方玩家的效果指定为对象）。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「秘旋谍」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54631665,0))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c54631665.thtg)
	e3:SetOperation(c54631665.thop)
	c:RegisterEffect(e3)
	-- 这张卡的控制者在每次自己结束阶段让自己墓地1只怪兽回到卡组。或者不回到卡组让这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c54631665.mtcon)
	e4:SetOperation(c54631665.mtop)
	c:RegisterEffect(e4)
end
-- 过滤场上除自身以外的「秘旋谍」卡。
function c54631665.tgtg(e,c)
	return c:IsSetCard(0xee) and c~=e:GetHandler()
end
-- 过滤卡组中可以加入手牌的「秘旋谍」怪兽。
function c54631665.thfilter(c)
	return c:IsSetCard(0xee) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测。
function c54631665.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以加入手牌的「秘旋谍」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c54631665.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行，从卡组选择1只「秘旋谍」怪兽加入手牌并给对方确认。
function c54631665.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「秘旋谍」怪兽。
	local g=Duel.SelectMatchingCard(tp,c54631665.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查当前是否为自己回合的结束阶段。
function c54631665.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤自己墓地中可以作为维持代价返回卡组的怪兽。
function c54631665.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
-- 维持代价的执行，选择让墓地1只怪兽回到卡组或者破坏这张卡。
function c54631665.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中并高亮显示这张卡，提示正在处理其维持效果。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取自己墓地中所有可以返回卡组的怪兽。
	local g=Duel.GetMatchingGroup(c54631665.cfilter,tp,LOCATION_GRAVE,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		-- 墓地有怪兽时，让玩家选择“怪兽回到卡组”或“破坏这张卡”。
		sel=Duel.SelectOption(tp,aux.Stringid(54631665,1),aux.Stringid(54631665,2))  --"自己墓地1只怪兽回到卡组/破坏这张卡"
	else
		-- 墓地没有怪兽时，强制玩家选择“破坏这张卡”。
		sel=Duel.SelectOption(tp,aux.Stringid(54631665,2))+1  --"破坏这张卡"
	end
	if sel==0 then
		-- 提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 将选中的墓地怪兽作为维持代价返回卡组并洗牌。
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_COST)
	else
		-- 作为未支付维持代价的惩罚，将这张卡破坏。
		Duel.Destroy(c,REASON_COST)
	end
end
