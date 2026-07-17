--神芸学徒 ファインメルト
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己可以抽1张。
-- ②：对方不能把自己场上的6星以下的「神艺」怪兽作为效果的对象。
-- ③：自己·对方的主要阶段，自己场上的怪兽的种族是3种类以上的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化，那些攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 初始化函数：注册这张卡的三个效果，e1为手卡发动的起动效果（从手卡特殊召唤并可抽卡，1回合1次），e2为在怪兽区存在的永续效果（保护自己场上的「神艺」怪兽不被对方取为效果对象），e3为二速诱发即时效果（将对方场上全部表侧表示怪兽的效果无效化并把攻击力减半，1回合1次）
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方不能把自己场上的6星以下的「神艺」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ctfilter)
	-- 设定永续效果的判定值：只有当效果的使用者是这张卡的控制者本人时才不会成为效果对象，即只防止对方的卡取对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己·对方的主要阶段，自己场上的怪兽的种族是3种类以上的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化，那些攻击力直到回合结束时变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自己场上表侧表示的「神艺」（系列编号0x1cd）卡
function s.cfilter(c)
	return c:IsSetCard(0x1cd) and c:IsFaceup()
end
-- ①效果的发动条件函数：自己场上存在「神艺」卡时才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（怪兽区和魔法·陷阱区）是否存在至少1张表侧表示的「神艺」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的目标函数：先检查自己主要怪兽区是否有空位且这张卡可以被特殊召唤，然后设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动可行性检查（chk==0时）：自己主要怪兽区存在可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次连锁将处理1张特殊召唤（这张卡本身），供星尘龙等效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：把这张卡从手卡特殊召唤，特殊召唤成功后若自己可以抽卡并选择「是」，则中断处理后以效果抽1张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁相关（仍在手卡），并将其以表侧表示特殊召唤到自己场上，且特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己可以效果抽1张卡
		and Duel.IsPlayerCanDraw(tp,1)
		-- 询问自己「是否抽卡？」，选择「是」才继续执行抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
		-- 中断当前效果处理，使之后的抽卡视为与特殊召唤不同时处理，避免错过时点
		Duel.BreakEffect()
		-- 自己以效果原因抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②效果的永续目标过滤函数：适用于自己场上表侧表示的6星以下的「神艺」怪兽
function s.ctfilter(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1cd) and c:IsLevelBelow(6)
end
-- ③效果的发动条件函数：自己场上表侧表示怪兽的种族有3种类以上，且当前是自己或对方的主要阶段
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己怪兽区全部表侧表示怪兽组成卡组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 判断自己场上怪兽的种族种类数大于2（即3种类以上），并且当前处于主要阶段
	return g:GetClassCount(Card.GetRace)>2 and Duel.IsMainPhase()
end
-- ③效果的目标函数：先检查对方场上存在表侧表示怪兽，然后取得对方场上全部表侧表示怪兽并设置效果无效的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动可行性检查（chk==0时）：对方场上存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方怪兽区全部表侧表示怪兽组成卡组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：声明本次连锁将对方场上全部表侧表示怪兽作为效果无效化的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ③效果的处理函数：对对方场上全部表侧表示怪兽逐一注册使效果无效化的单体效果（含相关连锁无效），刷新无效状态后，再逐一把那些怪兽的攻击力变成一半（向上取整），直到回合结束
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方怪兽区全部表侧表示怪兽组成卡组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历该卡组中的每一只对方怪兽
	for tc in aux.Next(g) do
		-- 使与该怪兽有关的连锁全部无效化（该怪兽里侧表示时重置）
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 手动刷新场上卡的无效状态，使刚才注册的无效化立即生效
	Duel.AdjustInstantly()
	-- 再次遍历该卡组中的每一只对方怪兽
	for tc in aux.Next(g) do
		local atk=tc:GetAttack()
		-- 那些攻击力直到回合结束时变成一半
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e3)
	end
end
