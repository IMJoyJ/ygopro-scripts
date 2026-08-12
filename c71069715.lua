--DDリビルド
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「契约书」卡不会被对方的效果破坏。
-- ②：把墓地的这张卡除外，以这张卡以外的除外的最多3张自己的「DD」卡为对象才能发动。那些卡回到卡组。
function c71069715.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「契约书」卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c71069715.indtg)
	-- 设置不会被破坏的抗性来源为对方的效果。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以这张卡以外的除外的最多3张自己的「DD」卡为对象才能发动。那些卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71069715,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	-- 将墓地的这张卡除外作为发动的代价。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c71069715.tdtg)
	e3:SetOperation(c71069715.tdop)
	c:RegisterEffect(e3)
end
-- 过滤不受破坏效果影响的卡片，限定为「契约书」卡片。
function c71069715.indtg(e,c)
	return c:IsSetCard(0xae)
end
-- 过滤满足回到卡组条件的卡片：表侧表示的「DD」卡且可以回到卡组。
function c71069715.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsAbleToDeck()
end
-- 效果2的发动准备与合法性检测（包括判定是否能选择合法的除外「DD」卡作为对象，以及自身是否正在连锁中）。
function c71069715.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c71069715.tdfilter(chkc) and chkc~=e:GetHandler() end
	-- 判定除外区是否存在至少1张除这张卡以外的、可以回到卡组的自己的「DD」卡。
	if chk==0 then return Duel.IsExistingTarget(c71069715.tdfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除这张卡以外的除外的最多3张自己的「DD」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c71069715.tdfilter,tp,LOCATION_REMOVED,0,1,3,e:GetHandler())
	-- 设置连锁信息，表明此效果的操作分类为回到卡组，操作对象为选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果2的效果处理，将作为对象的卡片送回卡组并洗牌。
function c71069715.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对该效果有效的对象卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些卡片送回持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
