--魂のリレー
-- 效果：
-- ①：从手卡把1只怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己受到的全部伤害变成0。那只怪兽从场上离开时对方决斗胜利。
function c42776960.initial_effect(c)
	-- ①：从手卡把1只怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己受到的全部伤害变成0。那只怪兽从场上离开时对方决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42776960.target)
	e1:SetOperation(c42776960.activate)
	c:RegisterEffect(e1)
end
-- 过滤出能够被本次效果特殊召唤的手牌怪兽，即判断手牌怪兽c是否满足被玩家tp通过效果e特殊召唤的合法条件（不忽略召唤条件与苏生限制）。
function c42776960.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的合法检测：自己的主要怪兽区有空位，且手牌中存在至少1只满足特殊召唤条件的怪兽。
function c42776960.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只通过c42776960.filter筛选、可被本次效果特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c42776960.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将要把1张手牌怪兽特殊召唤，操作对象来自我方手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌选择1只怪兽特殊召唤；若成功，则给那只怪兽附加“自己受到的全部伤害变成0”和“离场时对方决斗胜利”的持续效果。
function c42776960.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方场上没有可用的主要怪兽区空格，则效果处理不执行，直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选并选择1只满足条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c42776960.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 以表侧表示形式将选择的怪兽特殊召唤（正式处理开始，进入特殊召唤步骤）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己受到的全部伤害变成0。
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
		-- 那只怪兽从场上离开时对方决斗胜利。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetLabel(1-tp)
		e3:SetOperation(c42776960.leaveop)
		e3:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD+RESET_OVERLAY)
		tc:RegisterEffect(e3,true)
		-- 结束特殊召唤步骤，完成整个特殊召唤处理，使特殊召唤的怪兽正式登场。
		Duel.SpecialSummonComplete()
	end
end
-- 伤害减免效果的适用条件：该怪兽的控制者仍是其持有者（即原本召唤的玩家），确保“自己受到的全部伤害变成0”只对发动玩家生效。
function c42776960.con(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 怪兽离场时触发的效果：设置胜利原因为“魂之接力”（0x1a），然后使该效果记录的对手玩家获得决斗胜利。
function c42776960.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_RELAY_SOUL=0x1a
	-- 以魂之接力对应的胜利代码，让e:GetLabel()所代表的玩家（原对手）获得本场决斗的胜利。
	Duel.Win(e:GetLabel(),WIN_REASON_RELAY_SOUL)
end
