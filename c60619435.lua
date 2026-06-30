--G・ボール・シュート
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡发动的回合的自己主要阶段才能发动。从自己墓地选1只6星以下的昆虫族怪兽特殊召唤。
-- ②：把手卡1只昆虫族怪兽给对方观看，以对方场上1只表侧表示怪兽和持有比给人观看的怪兽低的攻击力的自己场上1只昆虫族怪兽为对象才能发动。那2只怪兽的控制权交换。这个效果让自己得到控制权的怪兽变成昆虫族。
function c60619435.initial_effect(c)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。从自己墓地选1只6星以下的昆虫族怪兽特殊召唤。
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
-- 卡片发动时在自身注册标识效果以记录发动回合
function c60619435.reg(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(60619435,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 墓地特殊召唤效果的判定条件（仅在该卡发动的回合可以发动）
function c60619435.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(60619435)~=0
end
-- 墓地中6星以下的昆虫族怪兽的过滤条件
function c60619435.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地特殊召唤效果的靶向/基本发动条件检测与提示
function c60619435.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在可特殊召唤的符合条件怪兽
		and Duel.IsExistingMatchingCard(c60619435.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示对方玩家正在发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置“从墓地特殊召唤怪兽”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 墓地特殊召唤效果的执行函数
function c60619435.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空余怪兽区域则无法继续执行
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只符合条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c60619435.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 手卡中可供展示的昆虫族怪兽的过滤条件
function c60619435.costfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and not c:IsPublic()
			-- 检查自己场上是否存在攻击力低于展示怪兽且满足控制权交换条件的昆虫族怪兽
			and Duel.IsExistingMatchingCard(c60619435.sfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c:GetAttack())
end
-- 自己场上满足控制权交换条件的昆虫族怪兽的过滤条件
function c60619435.sfilter(c,e,tp,atk)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsCanBeEffectTarget(e) and c:GetAttack()<atk
		-- 检查该怪兽是否能改变控制权，以及交换后是否有可用的怪兽区
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 对方场上满足控制权交换条件的表侧表示怪兽的过滤条件
function c60619435.ofilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
		-- 检查对方怪兽是否能改变控制权，以及交换后是否有可用的怪兽区
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 控制权交换效果的靶向/基本发动条件检测与对象选择
function c60619435.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取手卡中所有可展示的昆虫族怪兽
	local mg=Duel.GetMatchingGroup(c60619435.costfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 获取对方场上所有可作为对象的怪兽
	local emg=Duel.GetMatchingGroup(c60619435.ofilter,tp,0,LOCATION_MZONE,nil,e,1-tp)
	if chk==0 then return e:IsCostChecked() and #mg>0 and #emg>0 end
	-- 提示玩家选择要给对方确认的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1只昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c60619435.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的手卡怪兽向对方展示
	Duel.ConfirmCards(1-tp,g)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	-- 将自己手卡洗切
	Duel.ShuffleHand(tp)
	-- 提示玩家选择自己场上要交换控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只攻击力较低的昆虫族怪兽作为效果的对象
	local g1=Duel.SelectTarget(tp,c60619435.sfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,atk)
	-- 提示玩家选择对方场上要交换控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	local g2=Duel.SelectTarget(tp,c60619435.ofilter,tp,0,LOCATION_MZONE,1,1,nil,e,1-tp)
	g1:Merge(g2)
	-- 设置“两只怪兽交换控制权”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 控制权交换效果的执行函数
function c60619435.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetTargetsRelateToChain()
	local tc=g:Filter(Card.IsControler,nil,tp):GetFirst()
	local tc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if tc and tc2 then
		-- 将两个对象的控制权进行交换，并判断是否成功
		if Duel.SwapControl(tc,tc2) then
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
