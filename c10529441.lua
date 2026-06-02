--嗚呼な落とし穴
-- 效果：
-- ①：对方把怪兽特殊召唤的回合，对方场上的怪兽的效果发动时才能发动。那只把效果发动的怪兽破坏。那之后，那只怪兽存在过的区域的前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）有对方的卡存在的场合，那些全部破坏。
local s,id,o=GetID()
-- 初始化卡片效果与全局特殊召唤记录注册
function s.initial_effect(c)
	-- ①：对方把怪兽特殊召唤的回合，对方场上的怪兽的效果发动时才能发动。那只把效果发动的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- ①：对方把怪兽特殊召唤的回合，对方场上的怪兽的效果发动时才能发动。那只把效果发动的怪兽破坏。那之后，那只怪兽存在过的区域的前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）有对方的卡存在的场合，那些全部破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		-- 将用于全局记录特殊召唤事实的辅助效果注册到全局环境中
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局特殊召唤检测效果的执行逻辑（若对方特殊召唤怪兽，则为其注册在回合内有效的特殊召唤标记）
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历在当前事件中特殊召唤成功的所有怪兽卡片
	for tc in aux.Next(eg) do
		-- 为特殊召唤了怪兽的玩家注册全局标识效果，用于标记该回合有特殊召唤动作，持续到回合结束
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果发动的条件判定（判定必须在对方怪兽在场上发动怪兽效果的连锁上，且对方在该回合进行过特殊召唤）
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- 判定对方在该回合是否有特殊召唤过怪兽的全局标记
		and Duel.GetFlagEffect(1-tp,id)>0
end
-- 效果发动的目标判定与操作信息注册（判定发动效果的怪兽可破坏，并向系统注册全部待破坏卡片的信息）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsDestructable() end
	-- 获取对方场上与发动效果怪兽位置相邻（前面·后面·相邻的怪兽区域及魔陷区域）的所有对方卡片
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,rc:GetSequence(),1-tp)
	g:AddCard(rc)
	-- 向系统注册效果分类信息为：破坏，对象为发动效果的怪兽及其周围相邻区域的全部卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤目标卡片是否在发动效果怪兽的前面·后面·相邻的区域（包括怪兽区域及魔法与陷阱区域）的过滤函数
function s.desfilter(c,seq,tp)
	local cseq=c:GetSequence()
	local cloc=c:GetLocation()
	if c:GetControler()~=tp then
		if not (seq==1 or seq==3) then return end
		return seq==1 and cseq==6 or seq==3 and cseq==5
	end
	if cloc==LOCATION_SZONE then
		if cseq>=5 then return false end
		if seq<5 then return cseq==seq end
	end
	if cloc==LOCATION_MZONE then
		if seq<5 then
			if cseq>=5 then return seq==1 and cseq==5 or seq==3 and cseq==6 end
			if cseq<5 then return math.abs(cseq-seq)==1 end
		end
		if seq>=5 then return seq==5 and cseq==1 or seq==6 and cseq==3 end
	end
	return false
end
-- 效果处理的主体逻辑（破坏发动效果的怪兽，那之后将该怪兽存在过的相邻区域内的全部对方卡片破坏）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) and rc:IsLocation(LOCATION_MZONE) then
		local seq=rc:GetSequence()
		-- 执行对发动效果怪兽的破坏，成功破坏时执行后续的区域卡片破坏处理
		if Duel.Destroy(rc,REASON_EFFECT)~=0 then
			-- 效果处理时再次获取已被破坏怪兽在场上存在过的位置的相邻区域内属于对方的所有卡片
			local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,seq,rc:GetPreviousControler())
			-- 中断当前效果，使之后的相邻区域破坏与前面的破坏不视为同时处理（造成错时点）
			Duel.BreakEffect()
			-- 将被选中的相邻区域内存在的所有对方卡片全部破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
