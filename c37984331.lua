--真エクゾディア
-- 效果：
-- 这张卡在怪兽区域存在，这张卡以外的双方场上的怪兽只有「被封印」通常怪兽4种类的场合，从这张卡的控制者来看的对方决斗胜利。
function c37984331.initial_effect(c)
	-- 效果原文内容：这张卡在怪兽区域存在，这张卡以外的双方场上的怪兽只有「被封印」通常怪兽4种类的场合，从这张卡的控制者来看的对方决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c37984331.condition)
	e1:SetOperation(c37984331.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：表侧表示、卡名含有'被封印'、通常怪兽
function c37984331.winfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x40) and c:IsType(TYPE_NORMAL)
end
-- 过滤函数：不满足winfilter条件的卡
function c37984331.cfilter(c)
	return not c37984331.winfilter(c)
end
-- 条件判断函数：统计满足winfilter条件的卡的种类数是否为4且不存在不满足条件的卡
function c37984331.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足winfilter条件的卡组
	local g=Duel.GetMatchingGroup(c37984331.winfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	local ct=g:GetClassCount(Card.GetCode)
	-- 判断种类数为4且不存在不满足条件的卡
	return ct==4 and not Duel.IsExistingMatchingCard(c37984331.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 效果处理函数：令对方决斗胜利并刷新场上状态
function c37984331.operation(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_TRUE_EXODIA = 0x20
	-- 令对方决斗胜利
	Duel.Win(1-tp,WIN_REASON_TRUE_EXODIA)
	-- 若当前无连锁则刷新场上状态
	if Duel.GetCurrentChain()==0 then Duel.Readjust() end
end
