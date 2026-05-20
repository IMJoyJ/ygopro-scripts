--神芸学徒 グラフレア
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「神艺」魔法卡在自己场上盖放。
-- ②：这张卡1回合只有1次不会被战斗破坏。
-- ③：以对方场上1张魔法·陷阱卡为对象才能发动（自己场上的怪兽的种族是3种类以上的场合，这个效果在对方回合也能发动）。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「神艺」魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
	-- ③：以对方场上1张魔法·陷阱卡为对象才能发动（自己场上的怪兽的种族是3种类以上的场合，这个效果在对方回合也能发动）。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	-- 设置效果3在自己场上怪兽种族不足3种类时作为起动效果发动
	e3:SetCondition(aux.NOT(s.descon))
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.descon)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示「神艺」卡的条件函数
function s.cfilter(c)
	return c:IsSetCard(0x1cd) and c:IsFaceup()
end
-- 效果1的发动条件：自己场上有「神艺」卡存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「神艺」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果1的发动准备与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡组中可盖放的「神艺」魔法卡的条件函数
function s.setfilter(c)
	return c:IsSetCard(0x1cd) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果1的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡，则将其特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查卡组中是否存在可盖放的「神艺」魔法卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择从卡组盖放1张「神艺」魔法卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否盖放？"
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组选择1张满足条件的「神艺」魔法卡
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 插入时点中断，使后续的盖放处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 将选择的「神艺」魔法卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 效果2的保护条件：仅在因战斗被破坏时适用
function s.valcon(e,re,r,rp)
	return r&REASON_BATTLE~=0
end
-- 效果3在对方回合也能发动的条件：自己场上的怪兽种族在3种类以上
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetRace)>2
end
-- 过滤魔法·陷阱卡的条件函数
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果3的发动准备与对象选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.desfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理中的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果3的效果处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将作为对象的卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
