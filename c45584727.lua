--ワルキューレの抱擁
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「女武神」怪兽不能特殊召唤。
-- ①：自己场上的怪兽只有「女武神」怪兽的场合，以自己场上1只攻击表示的「女武神」怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽变成守备表示，那只对方怪兽除外。
function c45584727.initial_effect(c)
	-- ①：自己场上的怪兽只有「女武神」怪兽的场合，以自己场上1只攻击表示的「女武神」怪兽和对方场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,45584727+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c45584727.rmcost)
	e1:SetCondition(c45584727.rmcon)
	e1:SetTarget(c45584727.rmtg)
	e1:SetOperation(c45584727.rmop)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在回合中特殊召唤的「女武神」怪兽数量
	Duel.AddCustomActivityCounter(45584727,ACTIVITY_SPSUMMON,c45584727.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为「女武神」卡
function c45584727.counterfilter(c)
	return c:IsSetCard(0x122)
end
-- 发动时检查是否为该回合第一次特殊召唤，若不是则不能发动
function c45584727.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合中是否已经进行过特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(45584727,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响全场的永续效果，禁止玩家特殊召唤非「女武神」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c45584727.splimit)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制效果的过滤函数，禁止非「女武神」怪兽特殊召唤
function c45584727.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x122)
end
-- 过滤函数，判断卡片是否为「女武神」卡
function c45584727.cfilter(c)
	return c:IsSetCard(0x122)
end
-- 过滤函数，判断卡片是否为里侧表示或非「女武神」卡
function c45584727.cfilter2(c)
	return c:IsFacedown() or not c:IsSetCard(0x122)
end
-- 效果发动条件函数，判断自己场上是否只有「女武神」怪兽
function c45584727.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「女武神」怪兽
	return Duel.IsExistingMatchingCard(c45584727.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在非「女武神」怪兽或里侧表示的怪兽
		and not Duel.IsExistingMatchingCard(c45584727.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，判断卡片是否为表侧攻击表示的「女武神」怪兽
function c45584727.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122) and c:IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤函数，判断卡片是否为表侧表示且能除外的怪兽
function c45584727.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果发动时的处理函数，检查是否满足选择对象的条件
function c45584727.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在满足条件的「女武神」攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c45584727.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在满足条件的表侧表示怪兽
		and Duel.IsExistingTarget(c45584727.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的「女武神」攻击表示怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c45584727.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的对方表侧表示怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c45584727.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g2:GetFirst())
	-- 设置效果处理信息，记录要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,1,0,0)
	-- 设置效果处理信息，记录要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
-- 效果处理函数，执行效果的处理流程
function c45584727.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取当前连锁中被选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 将选择的「女武神」怪兽变为守备表示，并确认目标怪兽有效
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 and hc:IsRelateToEffect(e) then
		-- 将对方怪兽除外
		Duel.Remove(hc,POS_FACEUP,REASON_EFFECT)
	end
end
