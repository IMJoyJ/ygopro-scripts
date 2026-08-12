--神芸学徒 ファインメルト
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，自己可以抽1张。
-- ②：对方不能把自己场上的6星以下的「神艺」怪兽作为效果的对象。
-- ③：自己·对方的主要阶段，自己场上的怪兽的种族是3种类以上的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化，那些攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 初始化并注册这张卡的三个效果：e1为手卡发动的起动效果（特殊召唤+抽卡，1回合1次），e2为场上永续效果（使己方6星以下「神艺」怪兽不能成为对方效果对象），e3为怪兽区的诱发即时效果（无效对方全场表侧怪兽并减半攻击力，1回合1次）
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
	-- 设定效果判定函数：仅当效果的操作者是这张卡的控制者本人时才生效，从而实现只有对方不能把符合条件的怪兽作为效果对象
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
-- 过滤函数：判断卡片是否为表侧表示的「神艺」卡（0x1cd为神艺系列字段）
function s.cfilter(c)
	return c:IsSetCard(0x1cd) and c:IsFaceup()
end
-- ①效果的发动条件判定：检查自己场上是否存在「神艺」卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「神艺」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的对象确认：检查自己怪兽区是否有空格且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可能性检查：自己主要怪兽区必须还有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣言将处理特殊召唤分类，对象为这张卡本身，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：这张卡从手卡特殊召唤成功后，若自己可以抽卡并选择抽卡，则中断时点抽1张
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与当前连锁关联，则将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 并且自己可以以效果抽1张卡
		and Duel.IsPlayerCanDraw(tp,1)
		-- 并且自己选择了「是」（询问是否抽卡）
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
		-- 中断当前效果处理，使之后的抽卡视为不同时处理（避免错时点问题）
		Duel.BreakEffect()
		-- 让自己以效果原因抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数：判断对方怪兽是否为自己场上表侧表示的6星以下的「神艺」怪兽（②效果保护对象）
function s.ctfilter(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1cd) and c:IsLevelBelow(6)
end
-- ③效果的发动条件判定：自己场上表侧表示怪兽的种族有3种类以上，且当前是自己或对方的主要阶段
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己怪兽区所有表侧表示怪兽的卡组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 判定自己场上怪兽的种族数量大于2（即3种类以上），且现在处于主要阶段
	return g:GetClassCount(Card.GetRace)>2 and Duel.IsMainPhase()
end
-- ③效果的对象确认与操作信息设置：确认对方场上有表侧表示怪兽，并宣言要无效的对象组
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可能性检查：对方怪兽区必须存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方怪兽区所有表侧表示怪兽的卡组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：宣言将处理效果无效分类，对象为对方场上全部表侧表示怪兽，数量为其张数
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ③效果的处理：使对方场上全部表侧表示怪兽的效果无效化，随后将这些怪兽的攻击力直到回合结束时变成一半（向上取整）
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方怪兽区所有表侧表示怪兽的卡组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历卡组中的每一只对方表侧表示怪兽
	for tc in aux.Next(g) do
		-- 将与该怪兽有关的连锁全部无效化（直到其变为里侧表示时重置）
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示怪兽的效果无效化，
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果无效化，
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 立即手动刷新场上卡的无效状态，使刚赋予的无效效果即时生效
	Duel.AdjustInstantly()
	-- 再次遍历卡组中的每一只对方表侧表示怪兽
	for tc in aux.Next(g) do
		local atk=tc:GetAttack()
		-- 那些攻击力直到回合结束时变成一半。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e3)
	end
end
