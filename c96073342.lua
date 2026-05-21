--セフィラの星戦
-- 效果：
-- 「神数的星战」在1回合只能发动1张。自己的灵摆区域有2张「神数」卡存在的场合，这张卡的发动从手卡也能用。
-- ①：以自己场上1张「神数」卡和对方场上1张卡为对象才能发动。那些卡破坏。
function c96073342.initial_effect(c)
	-- 「神数的星战」在1回合只能发动1张。①：以自己场上1张「神数」卡和对方场上1张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,96073342+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c96073342.target)
	e1:SetOperation(c96073342.activate)
	c:RegisterEffect(e1)
	-- 自己的灵摆区域有2张「神数」卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96073342,0))  --"适用「神数的星战」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c96073342.handcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「神数」卡
function c96073342.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc4)
end
-- 效果①的发动准备与对象合法性检测
function c96073342.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 检查自己场上是否存在除这张卡以外的1张表侧表示的「神数」卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c96073342.filter,tp,LOCATION_ONFIELD,0,1,c)
		-- 检查对方场上是否存在至少1张卡作为可选对象
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「神数」卡作为对象
	local g1=Duel.SelectTarget(tp,c96073342.filter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果①的效果处理（破坏选中的卡）
function c96073342.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些卡因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 手卡发动条件判断函数
function c96073342.handcon(e)
	-- 检查自己的灵摆区域是否存在2张「神数」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,2,nil,0xc4)
end
