--Jo－P.U.N.K.ナシワリ・サプライズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上盖放的1张卡为对象才能发动。那张卡破坏。自己场上有「朋克」怪兽存在的场合，也能作为代替以对方场上1张表侧表示的卡为对象。
function c70070211.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上盖放的1张卡为对象才能发动。那张卡破坏。自己场上有「朋克」怪兽存在的场合，也能作为代替以对方场上1张表侧表示的卡为对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,70070211+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c70070211.destg)
	e1:SetOperation(c70070211.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为里侧表示，或者在满足check条件（自己场上有「朋克」怪兽）时为表侧表示
function c70070211.filter(c,check)
	return c:IsFacedown() or c:IsFaceup() and check
end
-- 过滤函数：检查是否为表侧表示的「朋克」怪兽
function c70070211.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171)
end
-- 效果①的发动准备：检查并选择对方场上1张符合条件的卡作为对象，并设置破坏的操作信息
function c70070211.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在表侧表示的「朋克」怪兽
	local check=Duel.IsExistingMatchingCard(c70070211.cfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c70070211.filter(chkc,check) end
	-- 在发动阶段的检查中，判断对方场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(c70070211.filter,tp,0,LOCATION_ONFIELD,1,nil,check) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张符合条件的卡作为对象
	local g=Duel.SelectTarget(tp,c70070211.filter,tp,0,LOCATION_ONFIELD,1,1,nil,check)
	-- 设置效果处理信息：破坏选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理：破坏作为对象的卡
function c70070211.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
