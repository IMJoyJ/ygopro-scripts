--真エクゾディア
-- 效果：
-- 这张卡在怪兽区域存在，这张卡以外的双方场上的怪兽只有「被封印」通常怪兽4种类的场合，从这张卡的控制者来看的对方决斗胜利。
function c37984331.initial_effect(c)
	-- 这张卡在怪兽区域存在，这张卡以外的双方场上的怪兽只有「被封印」通常怪兽4种类的场合，从这张卡的控制者来看的对方决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c37984331.condition)
	e1:SetOperation(c37984331.operation)
	c:RegisterEffect(e1)
end
-- 判定一只怪兽是否为满足特殊胜利条件所需的「被封印」通常怪兽：必须是表侧表示、属于「被封印」系列（0x40）且为通常怪兽。
function c37984331.winfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x40) and c:IsType(TYPE_NORMAL)
end
-- 反向过滤函数：任何不满足 winfilter 条件的怪兽都会通过（返回 true），用于检测场上是否存在会破坏特殊胜利条件的其他怪兽。
function c37984331.cfilter(c)
	return not c37984331.winfilter(c)
end
-- 特殊胜利的满足条件：真艾克佐迪亚在怪兽区存在；查看双方怪兽区，排除自身后，所有怪兽都必须是「被封印」通常怪兽，且其卡名种类恰好为4种；同时不存在任何一只非此类怪兽。若满足则返回 true，使效果进入处理。
function c37984331.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方怪兽区中除真艾克佐迪亚自身以外的所有表侧表示「被封印」通常怪兽，作为候选集合 g。
	local g=Duel.GetMatchingGroup(c37984331.winfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	local ct=g:GetClassCount(Card.GetCode)
	-- 判断 g 中卡名种类数是否为4，并且排除自身后不存在任何一张不是「被封印」通常怪兽的卡，两者同时成立才满足特殊胜利条件。
	return ct==4 and not Duel.IsExistingMatchingCard(c37984331.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 效果处理：在条件满足后，令当前效果控制者的对手（1-tp）以“真艾克佐迪亚”的特殊胜利理由赢得决斗；若当前不在连锁处理中，则再刷新场上状态以确保后续判定同步。
function c37984331.operation(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_TRUE_EXODIA = 0x20
	-- 使 1-tp 玩家（即真艾克佐迪亚效果控制者视角的对方玩家）获得本场决斗的胜利，实现该卡的特殊胜利效果。
	Duel.Win(1-tp,WIN_REASON_TRUE_EXODIA)
	-- 当当前连锁序号为0（即没有正在处理的连锁）时，调用 Duel.Readjust() 重新刷新场上的卡片信息，避免状态更新不及时导致判定异常。
	if Duel.GetCurrentChain()==0 then Duel.Readjust() end
end
