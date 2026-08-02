--召喚獣ディー・アニマ
local s,id,o=GetID()
-- 声明初始化函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤条件：包含「召唤兽」怪兽的额外卡组怪兽2只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1e1),s.ffilter2,true)
	-- 这张卡特殊召唤成功时的效果处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 对方墓地发动的效果的处理
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	-- 该效果发动的代价：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 判断是否为额外卡组特殊召唤并且在怪兽区的过滤函数
function s.ffilter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
-- 特殊召唤成功时效果的检查和目标设定
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方怪兽区是否有额外卡组特殊召唤的怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
	-- 检查对方场上是否有魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return b1 or b2 end
	-- 提示玩家选择要适用的效果选项
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		-- 获取对方怪兽区中从额外卡组特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
		-- 设定将选择的怪兽破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	elseif op==2 then
		-- 获取对方场上的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 设定将选择的魔法·陷阱卡破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 特殊召唤成功时效果的执行过程
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取对方怪兽区中从额外卡组特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
		if g:GetCount()>0 then
			-- 将这些怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 获取对方场上的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		if g:GetCount()>0 then
			-- 将这些魔法·陷阱卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 对方墓地发动效果时的发动条件函数
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁的控制者和发生位置
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	-- 判断是否是对方在墓地发动的效果且该连锁可以被无效
	return tgp==1-tp and loc==LOCATION_GRAVE and Duel.IsChainDisablable(ev)
end
-- 筛选卡组中可以特殊召唤的「召唤兽」怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对方墓地发动效果时的检查和目标设定
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有主要的怪兽区空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断卡组中是否存在可以特殊召唤的「召唤兽」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定将该连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设定从卡组特殊召唤「召唤兽」怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 对方墓地发动效果时的执行过程
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断如果自己场上没有怪兽区空位则退出处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只「召唤兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 如果成功将该怪兽特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 将对方在墓地发动的效果无效
		Duel.NegateEffect(ev)
	end
end
