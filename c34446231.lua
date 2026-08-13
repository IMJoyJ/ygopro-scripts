--インフェルノイド・フラッド
-- 效果：
-- 包含「狱火机」怪兽的怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方把怪兽特殊召唤之际，把自己场上1只怪兽解放才能发动。那次特殊召唤无效，那些怪兽除外。
-- ②：从自己墓地有卡被除外的场合才能发动。场上1张卡除外。
-- ③：连接召唤的这张卡被对方破坏的场合才能发动。从卡组把1只「狱火机」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化卡片：启用复活限制（必须正规出场过才能从墓地/除外等特殊召唤）；添加连接召唤手续（2~4只怪兽且含『狱火机』怪兽）；注册①无效特殊召唤并除外、②自己墓地有卡除外时场上1张卡除外、③连接召唤的此卡被对方破坏时从卡组特召狱火机三个效果，并用各自CountLimit实现『这个卡名的①②③的效果1回合各能使用1次』。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用2～4只怪兽作为连接素材，且素材中至少包含1只『狱火机』怪兽（由s.lcheck检查），对应效果原文『包含「狱火机」怪兽的怪兽2只以上』。
	aux.AddLinkProcedure(c,nil,2,4,s.lcheck)
	-- ①：对方把怪兽特殊召唤之际，把自己场上1只怪兽解放才能发动。那次特殊召唤无效，那些怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤无效"
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地有卡被除外的场合才能发动。场上1张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡片除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ③：连接召唤的这张卡被对方破坏的场合才能发动。从卡组把1只「狱火机」怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接素材检查函数：判定素材组g中是否存在至少1只『狱火机』字段的怪兽，作为连接召唤手续的素材限制。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xbb)
end
-- ①效果的发动条件：对方玩家（ep）正在特殊召唤怪兽，且当前连锁数为0（即紧接那次特殊召唤发动，不处于其他连锁中）。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为：特殊召唤的玩家是对方，且当前连锁数为0。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 代价筛选函数：选择解放的卡必须是怪兽，用于①效果的解放代价。
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- ①效果的代价处理：检查自己场上是否有可解放的怪兽；有则选择并解放1只，作为发动代价。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只可解放的怪兽（满足s.costfilter）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) end
	-- 显示『请选择要解放的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只可解放的怪兽，作为代价。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil)
	-- 解放所选的怪兽，作为发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- ①效果发动时的目标/操作信息设定：确认当前玩家可以进行除外，并将正在特殊召唤的怪兽组eg设置为『无效召唤』和『除外』的对象。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：当前玩家可以进行除外操作。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 设置操作信息：本次效果包含『无效召唤』，对象为eg全部怪兽，数量为eg数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：本次效果包含『除外』，对象为eg全部怪兽，数量为eg数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- ①效果的解决：使该特殊召唤无效，并将那组怪兽表侧表示除外。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使eg中怪兽的特殊召唤无效。
	Duel.NegateSummon(eg)
	-- 将eg中的怪兽以表侧表示除外（效果处理）。
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
-- ②效果触发判定筛选：该被除外的卡在此之前是自己（tp）控制的，且之前在墓地。
function s.rmfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- ②效果的触发条件：eg中存在至少1张之前是自己墓地的卡（即自己墓地有卡被除外）。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rmfilter,1,nil,tp)
end
-- ②效果发动时：场上存在可除外的卡，取得所有可除外的卡集合，并设置操作信息为除外1张。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上（双方）存在至少1张可被除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取得场上所有可被除外的卡（作为可能除外对象）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次效果包含『除外』，可能除外对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的解决：从场上选择1张卡除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示『请选择要除外的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从场上选择1张可除外的卡。
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #sg>0 then
		-- 显示所选卡的选中动画，并记录为效果对象。
		Duel.HintSelection(sg)
		-- 将所选卡以表侧表示除外（效果处理）。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ③效果的触发条件：此卡为连接召唤且在主要怪兽区时被对方破坏（rp=1-tp），且破坏前由自己控制。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp
end
-- 特殊召唤对象筛选：『狱火机』怪兽，且可被特殊召唤（nocheck=true即无视召唤条件）。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xbb) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ③效果发动时判定：自己场上有空余怪兽区，且卡组存在符合条件的『狱火机』怪兽；设置操作信息为特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：卡组中存在至少1只满足s.spfilter的『狱火机』怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果的解决：从卡组选择1只『狱火机』怪兽，无视召唤条件特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有空余怪兽区，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示『请选择要特殊召唤的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足s.spfilter的『狱火机』怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上（nocheck=true，即无视召唤条件）。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
