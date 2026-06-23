--魂のリレー
-- 效果：
-- ①：从手卡把1只怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己受到的全部伤害变成0。那只怪兽从场上离开时对方决斗胜利。
function c42776960.initial_effect(c)
	-- ①：从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42776960.target)
	e1:SetOperation(c42776960.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查手牌中是否存在可以特殊召唤的怪兽
function c42776960.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时点，判断是否满足特殊召唤条件
function c42776960.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c42776960.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动处理，执行特殊召唤操作
function c42776960.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c42776960.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己受到的全部伤害变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetTargetRange(1,0)
		e1:SetCondition(c42776960.con)
		e1:SetValue(0)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 那只怪兽从场上离开时对方决斗胜利
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetLabel(1-tp)
		e3:SetOperation(c42776960.leaveop)
		e3:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD+RESET_OVERLAY)
		tc:RegisterEffect(e3,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 条件函数，判断效果是否作用于自己
function c42776960.con(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 离开场上的处理函数，令对方决斗胜利
function c42776960.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_RELAY_SOUL=0x1a
	-- 令对方以魂之接力的效果胜利
	Duel.Win(e:GetLabel(),WIN_REASON_RELAY_SOUL)
end
