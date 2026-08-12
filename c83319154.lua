--時空穿つ遡光
-- 效果：
-- ①：除这个回合召唤·反转召唤·特殊召唤的怪兽外的场上的怪兽的效果由对方发动时才能发动。那个发动无效。那之后，可以把除这个回合召唤·反转召唤·特殊召唤的怪兽外的对方场上的表侧表示怪兽全部里侧除外。
-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把1张陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果发动无效、被破坏时盖放陷阱卡的效果，并注册全局监听以标记本回合召唤·特殊召唤·反转召唤的怪兽
function s.initial_effect(c)
	-- ①：除这个回合召唤·反转召唤·特殊召唤的怪兽外的场上的怪兽的效果由对方发动时才能发动。那个发动无效。那之后，可以把除这个回合召唤·反转召唤·特殊召唤的怪兽外的对方场上的表侧表示怪兽全部里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把1张陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册全局效果监听，用于在此回合怪兽通常召唤、特殊召唤、反转召唤成功时注册标记
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		-- 在全局环境注册怪兽通常召唤成功监听效果
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 在全局环境注册怪兽特殊召唤成功监听效果
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		-- 在全局环境注册怪兽反转召唤成功监听效果
		Duel.RegisterEffect(ge3,0)
	end
end
-- 定义怪兽出场成功时的全局监听处理函数，为出场的怪兽注册存续至回合结束的标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历当前所有召唤、特殊召唤或反转召唤成功的怪兽
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_REMOVE+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 定义效果①发动的条件检查函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取引发当前连锁的效果发动时的卡片所在位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 验证是否为对方发动的场上怪兽效果、该怪兽未持有本回合召唤标记、且该连锁的发动能够被无效
	return ep==1-tp and re:GetHandler():GetFlagEffect(id)==0 and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义效果①发动的靶点与操作信息注册函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的操作信息为使引发当前连锁的效果发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 过滤在本回合未曾召唤·反转召唤·特殊召唤过，且能被里侧除外的表侧表示怪兽
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:GetFlagEffect(id)==0 and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 定义效果①发动的执行操作函数，尝试无效效果并发动后续的里侧除外效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效引发当前连锁的效果发动
	if Duel.NegateActivation(ev)
		-- 检查对方场上是否存在符合里侧除外条件的怪兽
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 询问玩家是否选择执行将场上怪兽里侧除外的效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽除外？"
		-- 获取对方场上符合除外条件的所有表侧表示怪兽组
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil,tp)
		if g:GetCount()>0 then
			-- 中断当前效果，以进行后续里侧除外的结算步骤
			Duel.BreakEffect()
			-- 将符合条件的对方场上表侧表示怪兽全部里侧表示除外
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
-- 定义效果②发动的条件检查函数，确认是被对方效果破坏的已盖放的自身
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤可从卡组盖放的陷阱卡
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 定义效果②发动的靶点选择与操作信息注册函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 验证当前卡组中是否存在可以盖放的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义效果②的执行操作函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张可盖放的陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的陷阱卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
