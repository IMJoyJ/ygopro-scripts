--シールド・ワーム
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，变成守备表示。再把自己场上表侧表示存在的昆虫族怪兽数量的卡从对方卡组上面送去墓地。
function c15939448.initial_effect(c)
	-- 创建一个诱发必发效果，对应通常召唤成功时的触发条件，设置效果描述为“卡组送墓”，并设置效果分类为改变表示形式和从卡组送墓，效果类型为单体诱发必发效果，触发事件为通常召唤成功
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15939448,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c15939448.condition)
	e1:SetTarget(c15939448.target)
	e1:SetOperation(c15939448.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果条件：判断该卡是否为表侧攻击表示
function c15939448.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤函数：筛选场上表侧表示存在的昆虫族怪兽
function c15939448.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 效果目标设定：检查是否满足条件，若满足则计算场上昆虫族怪兽数量，并设置操作信息为对方卡组送墓数量
function c15939448.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算场上表侧表示存在的昆虫族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c15939448.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置连锁操作信息，指定对方卡组送去墓地的数量
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
-- 效果处理函数：判断该卡是否仍然存在于场上且为表侧攻击表示，若是则将其变为守备表示，再根据场上昆虫族怪兽数量从对方卡组送墓相应数量的卡
function c15939448.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否仍然存在于场上且为表侧攻击表示，若是则将其变为守备表示
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		-- 再次计算场上表侧表示存在的昆虫族怪兽数量
		local ct=Duel.GetMatchingGroupCount(c15939448.filter,tp,LOCATION_MZONE,0,nil)
		if ct>0 then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 将对方卡组上方指定数量的卡送去墓地
			Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
		end
	end
end
