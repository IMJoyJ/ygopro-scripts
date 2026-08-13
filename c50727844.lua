--シンクロ・フォースバック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以最多有自己场上的同调怪兽种类数量的场上的怪兽为对象才能发动。那些怪兽回到手卡。
local s,id,o=GetID()
-- 定义并注册这张卡的①效果：创建魔法发动的自由连锁效果，分类为回手牌，取对象，并设置同名卡1回合1次、提示时点、目标与处理函数。
function s.initial_effect(c)
	-- 对应效果原文：“这个卡名的卡在1回合只能发动1张。①：以最多有自己场上的同调怪兽种类数量的场上的怪兽为对象才能发动。那些怪兽回到手卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选表侧表示的同调怪兽，用于统计自己场上同调怪兽的种类数。
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 目标选择函数整体：先处理连锁确认取对象合法性；再统计自己场上表侧同调怪兽的种类数作为可选数量上限；发动前需要满足有同调怪兽且场上存在可回手的怪兽；最后选择1到上限数量的怪兽作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 获取自己场上表侧表示的同调怪兽中不同卡名的数量，作为本次效果可以选择的对象数量上限。
	local ct=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then return ct>0
		-- 发动条件判定：必须自己场上有同调怪兽（ct>0），且场上至少存在1只可以被回手卡的效果对象的怪兽，才能发动。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者发送选择提示，提示文字为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从双方主要怪兽区选择1到ct张满足可回手条件的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	-- 登记本次连锁的回手牌操作信息，目标为已选择的那些怪兽，数量为实际选择数，用于时点检测和效果处理确认。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果处理函数：将当前连锁所对应（已选定的）全部对象怪兽返回持有者手卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行回手处理：将所有与当前连锁相关的对象卡送去其持有者的手卡，返回原因为效果所致。
	Duel.SendtoHand(Duel.GetTargetsRelateToChain(),nil,REASON_EFFECT)
end
