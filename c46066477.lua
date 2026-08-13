--エンタメ・バンド・ハリケーン
-- 效果：
-- 「娱乐乐队飓风」在1回合只能发动1张。
-- ①：以最多有自己场上的「娱乐伙伴」怪兽数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。
function c46066477.initial_effect(c)
	-- 「娱乐乐队飓风」在1回合只能发动1张。①：以最多有自己场上的「娱乐伙伴」怪兽数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,46066477+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46066477.target)
	e1:SetOperation(c46066477.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己场上表侧表示的「娱乐伙伴」怪兽，用于确定可选取对象数量上限。
function c46066477.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 发动时进行合法性判断：自己场上有表侧「娱乐伙伴」怪兽，且对方场上有能够回手牌的卡；连锁处理中若选择对象则校验该卡位于对方场上且可回手牌。
function c46066477.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 非效果处理时点（chk==0）且发动条件检查：确认自己场上有至少1只表侧表示的「娱乐伙伴」怪兽，作为选择对象数量上限的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c46066477.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认对方场上有至少1张能够回手牌的卡，以满足「以对方场上的卡为对象」的前提。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 统计自己场上表侧表示的「娱乐伙伴」怪兽数量，作为本卡最多可选对方场上卡的数量上限。
	local ct=Duel.GetMatchingGroupCount(c46066477.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 向操作玩家显示选择提示，提示内容为‘请选择要返回手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1张以上、最多ct张（ct为自己场上「娱乐伙伴」怪兽数量）能够回手牌的卡作为效果对象，并将这些卡登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 登记本次连锁的处理信息：将要进行回手牌处理，对象为已选中的那些卡，数量为选中卡数，所属玩家和位置参数为0。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时获取连锁对象中仍与效果关联的卡，若存在则将其全部返回持有者手卡。
function c46066477.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡组，并筛选出仍然与该效果存在关联的卡（例如未离开场上或未被无效）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选后的对象卡返回持有者手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
