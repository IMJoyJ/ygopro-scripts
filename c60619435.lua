--G・ボール・シュート
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡发动的回合的自己主要阶段才能发动。从自己墓地选1只6星以下的昆虫族怪兽特殊召唤。
-- ②：把手卡1只昆虫族怪兽给对方观看，以对方场上1只表侧表示怪兽和持有比给人观看的怪兽低的攻击力的自己场上1只昆虫族怪兽为对象才能发动。那2只怪兽的控制权交换。这个效果让自己得到控制权的怪兽变成昆虫族。
function c60619435.initial_effect(c)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c60619435.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。从自己墓地选1只6星以下的昆虫族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60619435,0))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,60619435)
	e2:SetCondition(c60619435.spcon)
	e2:SetTarget(c60619435.sptg)
	e2:SetOperation(c60619435.spop)
	c:RegisterEffect(e2)
	-- ②：把手卡1只昆虫族怪兽给对方观看，以对方场上1只表侧表示怪兽和持有比给人观看的怪兽低的攻击力的自己场上1只昆虫族怪兽为对象才能发动。那2只怪兽的控制权交换。这个效果让自己得到控制权的怪兽变成昆虫族。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60619435,1))  --"交换控制权"
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,60619435)
	e3:SetTarget(c60619435.target)
	e3:SetOperation(c60619435.activate)
	c:RegisterEffect(e3)
end
-- 在魔法卡发动成功时，为该卡注册一个在本回合内有效的Flag，用于标记该卡是在本回合发动的
function c60619435.reg(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(60619435,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查该卡是否存在发动回合的Flag，作为①效果的发动条件
function c60619435.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(60619435)~=0
end
-- 过滤自己墓地中等级6以下且可以特殊召唤的昆虫族怪兽
function c60619435.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查怪兽区域空位和墓地中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c60619435.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c60619435.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了“从墓地特殊召唤”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的实际处理：从自己墓地选择1只满足条件的昆虫族怪兽特殊召唤
function c60619435.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c60619435.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡中未公开的昆虫族怪兽，且自己场上存在攻击力比该怪兽低、能作为效果对象且能交换控制权的昆虫族怪兽
function c60619435.costfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and not c:IsPublic()
			-- 检查自己场上是否存在攻击力低于该手卡怪兽、且满足控制权交换条件的昆虫族怪兽
			and Duel.IsExistingMatchingCard(c60619435.sfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c:GetAttack())
end
-- 过滤自己场上表侧表示、攻击力低于指定数值、能作为效果对象、能改变控制权且交换后有可用怪兽区域的昆虫族怪兽
function c60619435.sfilter(c,e,tp,atk)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsCanBeEffectTarget(e) and c:GetAttack()<atk
		-- 检查该怪兽是否可以改变控制权，且该怪兽离开后自己场上是否有可用于控制权交换的怪兽区域空位
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤对方场上表侧表示、能作为效果对象、能改变控制权且交换后有可用怪兽区域的怪兽
function c60619435.ofilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
		-- 检查该怪兽是否可以改变控制权，且该怪兽离开后对方场上是否有可用于控制权交换的怪兽区域空位
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- ②效果的发动准备：展示手卡1只昆虫族怪兽，并选择自己与对方场上各1只满足条件的怪兽作为效果对象，设置控制权交换的操作信息
function c60619435.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取手卡中所有满足展示条件的昆虫族怪兽组
	local mg=Duel.GetMatchingGroup(c60619435.costfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 获取对方场上所有满足控制权交换条件的怪兽组
	local emg=Duel.GetMatchingGroup(c60619435.ofilter,tp,0,LOCATION_MZONE,nil,e,1-tp)
	if chk==0 then return e:IsCostChecked() and #mg>0 and #emg>0 end
	-- 提示玩家选择要给对方确认的手卡怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只满足条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c60619435.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的手卡怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	-- 重新洗切自己的手卡
	Duel.ShuffleHand(tp)
	-- 提示玩家选择要改变控制权的自己场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只攻击力低于展示怪兽且满足条件的昆虫族怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c60619435.sfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,atk)
	-- 提示玩家选择要改变控制权的对方场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的表侧表示怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c60619435.ofilter,tp,0,LOCATION_MZONE,1,1,nil,e,1-tp)
	g1:Merge(g2)
	-- 设置控制权交换的操作信息，表示将交换这2只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- ②效果的实际处理：交换作为对象的2只怪兽的控制权，并使自己获得控制权的怪兽种族变成昆虫族
function c60619435.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁处理时仍与该效果关联的对象怪兽组
	local g=Duel.GetTargetsRelateToChain()
	local tc=g:Filter(Card.IsControler,nil,tp):GetFirst()
	local tc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if tc and tc2 then
		-- 尝试交换这2只怪兽的控制权，若交换成功则继续处理
		if Duel.SwapControl(tc,tc2)~=0 then
			-- 这个效果让自己得到控制权的怪兽变成昆虫族。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_INSECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
		end
	end
end
