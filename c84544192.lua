--究極宝玉神 レインボー・ドラゴン オーバー・ドライブ
-- 效果：
-- 「究极宝玉神」怪兽＋「宝玉兽」怪兽×7
-- 自己对「究极宝玉神」怪兽的特殊召唤成功的决斗中，把自己的场上·墓地的上记卡除外的场合才能特殊召唤。
-- ①：除外的自己的「宝玉兽」怪兽是7种类以上的场合，这张卡的攻击力上升7000。
-- ②：自己·对方回合，把这个回合没有进行战斗的这张卡解放才能发动。场上的卡全部回到持有者卡组，选除外的自己的「宝玉兽」怪兽任意数量特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为1只「究极宝玉神」怪兽和7只「宝玉兽」怪兽。
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x2034),aux.FilterBoolFunction(Card.IsFusionSetCard,0x1034),7,true)
	-- 自己对「究极宝玉神」怪兽的特殊召唤成功的决斗中，把自己的场上·墓地的上记卡除外的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 自己对「究极宝玉神」怪兽的特殊召唤成功的决斗中，把自己的场上·墓地的上记卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ①：除外的自己的「宝玉兽」怪兽是7种类以上的场合，这张卡的攻击力上升7000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(7000)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，把这个回合没有进行战斗的这张卡解放才能发动。场上的卡全部回到持有者卡组，选除外的自己的「宝玉兽」怪兽任意数量特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.tdcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	if not s.global_flag then
		s.global_flag=true
		-- 自己对「究极宝玉神」怪兽的特殊召唤成功的决斗中，把自己的场上·墓地的上记卡除外的场合才能特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		-- 注册全局环境效果，用于记录玩家是否曾成功特殊召唤过「究极宝玉神」怪兽。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 成功特殊召唤怪兽时的全局监听操作，若特殊召唤的是「究极宝玉神」怪兽，则为该玩家注册标记。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历本次特殊召唤成功的所有怪兽。
	for tc in aux.Next(eg) do
		if tc:IsSetCard(0x2034) then
			-- 为特殊召唤该怪兽的玩家注册表示“曾成功特殊召唤过究极宝玉神”的全局标记。
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,0,0,0)
		end
	end
end
-- 过滤场上或墓地中可以作为特殊召唤素材除外的「究极宝玉神」或「宝玉兽」怪兽。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFusionSetCard(0x2034,0x1034) and c:IsAbleToRemoveAsCost()
end
-- 过滤作为特殊召唤素材的「究极宝玉神」怪兽，且除它之外还存在至少7只「宝玉兽」怪兽。
function s.cfilter1(c,g)
	return c:IsFusionSetCard(0x2034) and g:FilterCount(s.cfilter2,c)>=7
end
-- 过滤作为特殊召唤素材的「宝玉兽」怪兽。
function s.cfilter2(c)
	return c:IsFusionSetCard(0x1034)
end
-- 自身特殊召唤规则的条件判定。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家在决斗中是否曾成功特殊召唤过「究极宝玉神」怪兽，若没有则不能特殊召唤。
	if Duel.GetFlagEffect(tp,id)==0 then return false end
	-- 获取自己场上及墓地中所有可作为素材除外的怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g:IsExists(s.cfilter1,1,nil,g)
end
-- 自身特殊召唤规则的素材选择处理。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上及墓地中所有可作为素材除外的怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local sg=Group.CreateGroup()
	local cg=g:Filter(s.cfilter1,nil,g)
	-- 提示玩家选择要除外的「究极宝玉神」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc1=cg:SelectUnselect(sg,tp,false,true,1,1)
	if not tc1 then return false end
	cg=g:Filter(s.cfilter2,tc1)
	-- 提示玩家选择要除外的「宝玉兽」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选出正好7只「宝玉兽」怪兽。
	local sg2=cg:SelectSubGroup(tp,aux.TRUE,true,7,7)
	if not sg2 then return false end
	sg:AddCard(tc1)
	sg:Merge(sg2)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end
-- 自身特殊召唤规则的具体执行操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	-- 将选定的素材怪兽表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤除外状态的表侧表示「宝玉兽」怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 攻击力上升效果的条件判定。
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取除外状态的所有表侧表示「宝玉兽」怪兽。
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_REMOVED,0,nil)
	return g:GetClassCount(Card.GetCode)>=7
end
-- 效果②的发动代价判定与处理。
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetBattledGroupCount()==0 and c:IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(c,REASON_COST)
end
-- 过滤除外状态且可以特殊召唤的表侧表示「宝玉兽」怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在至少1张可以回到卡组的卡（不含自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		-- 并且检查除外状态是否存在至少1只可以特殊召唤的「宝玉兽」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 获取场上所有可以回到卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示此效果的处理包含将场上的卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
-- 效果②的效果处理函数。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可以回到卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将场上的卡全部回到持有者卡组并洗牌，若成功让至少1张卡回到卡组则继续处理。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 获取自己场上可用的怪兽区域数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选出任意数量（不超过可用怪兽区域数）除外的「宝玉兽」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,ft,nil,e,tp)
		if #sg>0 then
			-- 将选出的「宝玉兽」怪兽表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
