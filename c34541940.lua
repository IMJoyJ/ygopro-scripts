--神芸学徒 ファインメルト
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己可以抽1张。
-- ②：对方不能把自己场上的6星以下的「神艺」怪兽作为效果的对象。
-- ③：自己·对方的主要阶段，自己场上的怪兽的种族是3种类以上的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化，那些攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 注册三个效果：①特殊召唤、②不能成为对方效果对象、③无效化对方怪兽效果并减半攻击力
function s.initial_effect(c)
	-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己可以抽1张。
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
	-- 设置效果值为aux.tgoval函数，用于判断是否能成为对方效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：自己·对方的主要阶段，自己场上的怪兽的种族是3种类以上的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化，那些攻击力直到回合结束时变成一半。
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
-- 过滤函数：检查场上是否有「神艺」卡正面表示
function s.cfilter(c)
	return c:IsSetCard(0x1cd) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上有「神艺」卡正面表示
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有至少1张「神艺」卡正面表示
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动时点处理：判断是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理：特殊召唤自己并可能抽卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自己是否在连锁中且特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数：检查场上6星以下的「神艺」怪兽
function s.ctfilter(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1cd) and c:IsLevelBelow(6)
end
-- 效果③的发动条件：自己主要阶段且场上怪兽种族种类超过2种
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 判断场上怪兽种族种类是否超过2种且处于主要阶段
	return g:GetClassCount(Card.GetRace)>2 and Duel.IsMainPhase()
end
-- 效果③的发动时点处理：设置无效化对方怪兽效果
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否有正面表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：使对方怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果③的发动处理：使对方怪兽效果无效并减半攻击力
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历所有对方正面表示的怪兽
	for tc in aux.Next(g) do
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 刷新场上状态
		Duel.AdjustInstantly(tc)
		-- 设置目标怪兽攻击力减半
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(math.ceil(tc:GetAttack()/2))
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
