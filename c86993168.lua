--マッド・ハッカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方的结束阶段，把场上的这张卡除外才能发动。得到对方场上1只攻击力最低的怪兽的控制权。只要那只怪兽在自己场上表侧表示存在，那只怪兽不能把效果发动，自己不是连接怪兽不能从额外卡组特殊召唤。
function c86993168.initial_effect(c)
	-- ①：对方场上有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86993168,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,86993168)
	e1:SetCondition(c86993168.spcon)
	e1:SetTarget(c86993168.sptg)
	e1:SetOperation(c86993168.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把场上的这张卡除外才能发动。得到对方场上1只攻击力最低的怪兽的控制权。只要那只怪兽在自己场上表侧表示存在，那只怪兽不能把效果发动，自己不是连接怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86993168,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,86993169)
	-- 把场上的这张卡除外作为发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86993168.cttg)
	e2:SetOperation(c86993168.ctop)
	c:RegisterEffect(e2)
end
-- 检查特殊召唤的怪兽中是否有对方场上的怪兽
function c86993168.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 特殊召唤效果的发动准备与检测
function c86993168.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理
function c86993168.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤对方场上表侧表示且可以改变控制权的怪兽
function c86993168.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 控制权转移效果的发动准备与检测
function c86993168.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取对方场上所有满足控制权转移条件的怪兽
		local g=Duel.GetMatchingGroup(c86993168.ctfilter,tp,0,LOCATION_MZONE,nil)
		-- 检查对方场上是否有符合条件的怪兽，且自己场上有因控制权转移而可用的怪兽区域
		return g:GetCount()>0 and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
	end
	-- 设置控制权转移的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 控制权转移效果的处理，并对夺取的怪兽施加限制效果
function c86993168.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足控制权转移条件的怪兽
	local g=Duel.GetMatchingGroup(c86993168.ctfilter,tp,0,LOCATION_MZONE,nil)
	-- 若没有符合条件的怪兽或自己场上没有可用于控制权转移的怪兽区域，则不处理
	if g:GetCount()<=0 or Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)<=0 then return end
	local tg=g:GetMinGroup(Card.GetAttack)
	local tc=tg:GetFirst()
	if tg:GetCount()>1 then
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		local sg=tg:Select(tp,1,1,nil)
		-- 给选中的怪兽显示被选择的动画效果
		Duel.HintSelection(sg)
		tc=sg:GetFirst()
	end
	-- 让玩家获得目标怪兽的控制权
	Duel.GetControl(tc,tp)
	if not tc:IsControler(tp) then return end
	-- 自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c86993168.limitcon)
	e1:SetTarget(c86993168.splimit)
	tc:RegisterEffect(e1)
	-- 那只怪兽不能把效果发动
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetCondition(c86993168.limitcon)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
-- 限制效果的适用条件：该怪兽在自己场上表侧表示存在
function c86993168.limitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 限制不能从额外卡组特殊召唤连接怪兽以外的怪兽
function c86993168.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK)
end
