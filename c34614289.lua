--U.A.ストロングブロッカー
-- 效果：
-- 「超级运动员 强壮阻挡员」的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以让「超级运动员 强壮阻挡员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：1回合1次，对方对怪兽的特殊召唤成功时才能发动。那些怪兽的表示形式变更，那个效果无效。
function c34614289.initial_effect(c)
	-- ①：这张卡可以让「超级运动员 强壮阻挡员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,34614289+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c34614289.spcon)
	e1:SetTarget(c34614289.sptg)
	e1:SetOperation(c34614289.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方对怪兽的特殊召唤成功时才能发动。那些怪兽的表示形式变更，那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c34614289.postg)
	e2:SetOperation(c34614289.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查以玩家来看的场上是否存在满足条件的「超级运动员」怪兽（不包括自己）且该怪兽可以回到手卡作为费用
function c34614289.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(34614289) and c:IsAbleToHandAsCost()
		-- 检查场上是否有足够的怪兽区域来特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足，即场上是否存在符合条件的怪兽可以送回手卡
function c34614289.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1张满足条件的怪兽
	return Duel.IsExistingMatchingCard(c34614289.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 选择要送回手卡的怪兽，并设置为效果对象
function c34614289.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c34614289.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 将选中的怪兽送回手牌
function c34614289.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将怪兽送回手牌作为特殊召唤的费用
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 过滤函数，检查以指定玩家召唤的怪兽是否可以改变表示形式
function c34614289.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsCanChangePosition()
end
-- 设置连锁处理的目标怪兽组，并设置操作信息，包括改变表示形式和使效果无效
function c34614289.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c34614289.filter,1,nil,1-tp) end
	local g=eg:Filter(c34614289.filter,nil,1-tp)
	-- 设置当前处理的连锁的目标卡片组
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示要改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	-- 设置操作信息，表示要使目标怪兽的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 处理连锁效果，改变目标怪兽的表示形式并使效果无效
function c34614289.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中目标怪兽组，并筛选出与当前效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标怪兽改变为表侧守备表示或表侧攻击表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	-- 获取实际操作的卡片组
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=og:GetNext()
	end
end
