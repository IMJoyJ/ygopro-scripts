--召喚獣ディー・アニマ
local s,id,o=GetID()
-- 初始化卡片效果：注册①融合召唤手续、②特召成功破坏对方额外怪兽/魔陷效果、③二速除外自身特召卡组「召唤兽」并无效对方墓地效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合素材：1只「召唤兽」怪兽 + 1只从额外卡组特殊召唤的场上怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1e1),s.ffilter2,true)
	-- ①：这张卡特殊召唤成功的场合，选以下1个效果才能发动。「召唤兽 迪·阿尼玛」的这个效果1回合只能使用1次。●对方场上的从额外卡组特殊召唤的怪兽全部破坏。●对方场上的魔法·陷阱卡全部破坏。
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
	-- ②：对方在墓地把效果发动时，把场上的这张卡除外才能发动。从卡组把1只「召唤兽」怪兽特殊召唤，那个发动的效果无效。「召唤兽 迪·阿尼玛」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	-- ②效果发动Cost：把场上的这张卡表侧表示除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤条件：必须是位于场上且从额外卡组特殊召唤的怪兽
function s.ffilter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
-- 破坏效果准备：提供分支选择（破坏对方额外怪兽或魔陷）并设置对应破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
	-- 检查对方场上是否存在魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return b1 or b2 end
	-- 提示玩家从可执行的分支中选择一个破坏选项
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		-- 获取对方场上所有从额外卡组特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
		-- 设置连锁操作信息：破坏对方场上所有从额外卡组特殊召唤的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	elseif op==2 then
		-- 获取对方场上所有的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 设置连锁操作信息：破坏对方场上所有的魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 破坏效果处理：根据选中的分支破坏对方场上的额外怪兽或魔陷卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取对方场上所有从额外卡组特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
		if g:GetCount()>0 then
			-- 破坏对方场上所有从额外卡组特殊召唤的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 获取对方场上所有的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		if g:GetCount()>0 then
			-- 破坏对方场上所有的魔法·陷阱卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 无效效果发动条件：对方在墓地发动效果且该效果可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果的发动玩家及发动位置
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	-- 检查触发者是否为对方、位置是否为墓地且连锁效果可被无效
	return tgp==1-tp and loc==LOCATION_GRAVE and Duel.IsChainDisablable(ev)
end
-- 特召过滤条件：卡组中可以特殊召唤的「召唤兽」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 无效特召效果准备：检查怪兽区空位及卡组目标，设置无效与特召操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡离场后怪兽区域是否有空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组是否存在可特殊召唤的「召唤兽」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：使发动效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 无效特召效果处理：从卡组特召「召唤兽」怪兽，若成功则无效对方发动的效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只「召唤兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的怪兽表侧表示特殊召唤，并判断是否成功特召
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使对方发动的效果无效
		Duel.NegateEffect(ev)
	end
end
