--EMスプリングース
-- 效果：
-- 「娱乐伙伴 弹簧鹅」的效果1回合只能使用1次。
-- ①：自己主要阶段把墓地的这张卡除外，从自己的灵摆区域的「魔术师」卡、「娱乐伙伴」卡以及自己场上的灵摆怪兽之中以2张为对象才能发动。那2张卡回到持有者手卡。
function c128454.initial_effect(c)
	-- 『「娱乐伙伴 弹簧鹅」的效果1回合只能使用1次。①：自己主要阶段把墓地的这张卡除外，从自己的灵摆区域的「魔术师」卡、「娱乐伙伴」卡以及自己场上的灵摆怪兽之中以2张为对象才能发动。那2张卡回到持有者手卡。』
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(128454,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,128454)
	-- 设置发动效果所需的代价：将墓地中的这张卡除外，使用aux.bfgcost作为代价处理函数。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c128454.thtg)
	e1:SetOperation(c128454.thop)
	c:RegisterEffect(e1)
end
-- 定义对象筛选条件：满足以下任一条件且可以加入手牌的卡才能成为对象——（1）位于自己灵摆区域且属于「魔术师」或「娱乐伙伴」字段；（2）自己场上表侧表示且为灵摆怪兽。
function c128454.thfilter(c)
	return ((c:IsLocation(LOCATION_PZONE) and c:IsSetCard(0x9f,0x98))
		or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_PENDULUM))) and c:IsAbleToHand()
end
-- 发动时的目标选择处理：先确认指定对象是否合法（位于场上、由自己控制且满足筛选条件）；再检查是否存在至少2张可选对象；若满足，则提示玩家选择2张卡作为对象并设定返回手牌的操作信息。
function c128454.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c128454.thfilter(chkc) end
	-- 效果发动合法性检查：判断自己场上是否存在至少2张满足条件的卡可供选择。
	if chk==0 then return Duel.IsExistingTarget(c128454.thfilter,tp,LOCATION_ONFIELD,0,2,nil) end
	-- 向发动玩家显示选择提示，提示内容为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动玩家从自己场上（含灵摆区）选择2张符合条件的卡作为效果对象，并自动将所选卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c128454.thfilter,tp,LOCATION_ONFIELD,0,2,2,nil)
	-- 设置当前连锁的操作信息：本效果处理将把2张对象卡返回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理阶段的操作：获取连锁中记录的对象卡，并筛选出仍与该效果相关联的卡；若数量仍为2张，则将这些卡全部返回持有者手牌。
function c128454.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取对象卡组，并通过Card.IsRelateToEffect过滤掉已离场或不再与效果相关的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==2 then
		-- 将筛选后仍关联的2张对象卡以效果原因返回持有者手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
