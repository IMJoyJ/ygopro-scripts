--G・ボール・シュート
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡发动的回合的自己主要阶段才能发动。从自己墓地选1只6星以下的昆虫族怪兽特殊召唤。
-- ②：把手卡1只昆虫族怪兽给对方观看，以对方场上1只表侧表示怪兽和持有比给人观看的怪兽低的攻击力的自己场上1只昆虫族怪兽为对象才能发动。那2只怪兽的控制权交换。这个效果让自己得到控制权的怪兽变成昆虫族。
function c60619435.initial_effect(c)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。②：把手卡1只昆虫族怪兽给对方观看……（这个卡名的①②的效果1回合只能有1次使用其中任意1个）
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
-- 给这张卡注册1个直到结束阶段有效的标记效果，用于标记这张卡发动过的回合
function c60619435.reg(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(60619435,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查这张卡是否带有发动回合注册的标记，以此限定只能在这张卡发动的回合的自己主要阶段发动
function c60619435.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(60619435)~=0
end
-- 过滤器：这张卡是6星以下的昆虫族怪兽且可以被特殊召唤
function c60619435.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检查：自己场上要有空的主要怪兽区，且自己墓地存在可以特殊召唤的6星以下昆虫族怪兽
function c60619435.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只满足条件（6星以下昆虫族且可特殊召唤）的怪兽
		and Duel.IsExistingMatchingCard(c60619435.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方提示「巨强投球」选择了发动「墓地特殊召唤」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本连锁包含从墓地特殊召唤1只怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：若自己场上没有空的主要怪兽区则中断；否则从自己墓地选1只6星以下的昆虫族怪兽特殊召唤
function c60619435.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有可用的主要怪兽区则效果处理中断
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己墓地选1只6星以下的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c60619435.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的那只怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 展示用代价过滤器：手卡的这张卡是非公开状态的昆虫族怪兽，且自己场上存在攻击力比它低、可以作为对象的昆虫族怪兽
function c60619435.costfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and not c:IsPublic()
			-- 并且自己场上存在至少1只满足条件的怪兽（表侧表示昆虫族、可成为效果对象、攻击力低于给人观看的怪兽、可改变控制权）
			and Duel.IsExistingMatchingCard(c60619435.sfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c:GetAttack())
end
-- 自己场上对象过滤器：这张卡是表侧表示的昆虫族怪兽，可以成为效果对象，且攻击力低于给人观看的怪兽的攻击力
function c60619435.sfilter(c,e,tp,atk)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsCanBeEffectTarget(e) and c:GetAttack()<atk
		-- 并且这张卡可以改变控制权，且这张卡离开后对方场上要有可用来接收它的空的主要怪兽区
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 对方场上对象过滤器：这张卡是表侧表示怪兽，可以成为效果对象
function c60619435.ofilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
		-- 并且这张卡可以改变控制权，且这张卡离开后自己场上要有可用来接收它的空的主要怪兽区
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- ②效果的目标选择：先确认手卡有可给人观看的昆虫族怪兽且对方场上有可作为对象的怪兽；然后选1只手卡昆虫族怪兽给对方观看并记录其攻击力，洗切手卡；再以自己场上1只攻击力比它低的昆虫族怪兽和对方场上1只表侧表示怪兽为对象
function c60619435.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 取得自己手卡中所有满足展示条件的昆虫族怪兽
	local mg=Duel.GetMatchingGroup(c60619435.costfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 取得对方场上所有可作为对象的表侧表示怪兽
	local emg=Duel.GetMatchingGroup(c60619435.ofilter,tp,0,LOCATION_MZONE,nil,e,1-tp)
	if chk==0 then return e:IsCostChecked() and #mg>0 and #emg>0 end
	-- 提示玩家：请选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让自己从手卡选1只要给对方观看的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c60619435.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 把选中的那只怪兽给对方观看确认
	Duel.ConfirmCards(1-tp,g)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
	-- 提示玩家：请选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 以自己场上1只攻击力比给人观看的怪兽低的昆虫族怪兽为对象
	local g1=Duel.SelectTarget(tp,c60619435.sfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,atk)
	-- 提示玩家：请选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 以对方场上1只表侧表示怪兽为对象
	local g2=Duel.SelectTarget(tp,c60619435.ofilter,tp,0,LOCATION_MZONE,1,1,nil,e,1-tp)
	g1:Merge(g2)
	-- 设置操作信息：本连锁将交换这2只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理：取得与本连锁相关的2只对象怪兽，分别是自己和对方的怪兽，若都存在则交换它们的控制权，交换成功后让自己得到控制权的那只怪兽变成昆虫族
function c60619435.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁关联的对象怪兽组
	local g=Duel.GetTargetsRelateToChain()
	local tc=g:Filter(Card.IsControler,nil,tp):GetFirst()
	local tc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if tc and tc2 then
		-- 交换这2只怪兽的控制权，成功则继续处理
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
