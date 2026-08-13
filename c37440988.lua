--究極宝玉神 レインボー・オーバー・ドラゴン
-- 效果：
-- 「宝玉兽」怪兽×7
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上1只10星「究极宝玉神」怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：1回合1次，从自己墓地把1只「宝玉兽」怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
-- ②：把融合召唤的这张卡解放才能发动。场上的卡全部回到持有者卡组。这个效果在对方回合也能发动。
function c37440988.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以7只满足“「宝玉兽」字段”条件的怪兽为融合素材，从而支持通过融合召唤特殊召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1034),7,true)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件：只有融合召唤方式（SUMMON_TYPE_FUSION）才能让这张卡特殊召唤，其他非融合召唤方式（除后述的解放召唤）会被禁止。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把自己场上1只10星「究极宝玉神」怪兽解放的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c37440988.hspcon)
	e2:SetTarget(c37440988.hsptg)
	e2:SetOperation(c37440988.hspop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，从自己墓地把1只「宝玉兽」怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetDescription(aux.Stringid(37440988,0))  --"上升攻击力"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c37440988.atkcost)
	e3:SetOperation(c37440988.atkop)
	c:RegisterEffect(e3)
	-- ②：把融合召唤的这张卡解放才能发动。场上的卡全部回到持有者卡组。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37440988,1))  --"回到卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c37440988.tdcon)
	e4:SetCost(c37440988.tdcost)
	e4:SetTarget(c37440988.tdtg)
	e4:SetOperation(c37440988.tdop)
	c:RegisterEffect(e4)
end
-- 特殊召唤手续的解放对象过滤函数：判断怪兽是否为10星「究极宝玉神」且在己方场上，解放后额外卡组区域是否有空格，且该怪兽可作为此卡的融合素材。
function c37440988.hspfilter(c,tp,sc)
	-- 判定该怪兽属于「究极宝玉神」字段（0x2034）、等级为10、控制者为自己，并且解放它之后我方额外卡组怪兽区仍有空位可供此卡特殊召唤。
	return c:IsFusionSetCard(0x2034) and c:IsLevel(10) and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 特殊召唤手续的发动条件：当请求特殊召唤此卡时（c==nil时供规则查询），检查我方场上是否存在至少1只满足解放条件的10星「究极宝玉神」怪兽。
function c37440988.hspcon(e,c)
	if c==nil then return true end
	-- 用 Duel.CheckReleaseGroupEx 检查我方场上是否存在至少1只满足 hspfilter 的怪兽可用于本次特殊召唤解放（REASON_SPSUMMON）。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c37440988.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 选择要解放的怪兽：从可解放的怪兽中筛选出符合条件的「究极宝玉神」怪兽，提示玩家选择1只；选中后存入 e:SetLabelObject 并返回 true，否则 false。
function c37440988.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的怪兽组，再用 hspfilter 过滤出满足条件的10星「究极宝玉神」怪兽作为候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c37440988.hspfilter,nil,tp,c)
	-- 显示选择提示：‘请选择要解放的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理：取出之前选中的怪兽，将其设为此卡的融合素材，并解放该怪兽，完成从额外卡组的特殊召唤手续。
function c37440988.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 解放选中的怪兽，解放原因记为特殊召唤（REASON_SPSUMMON）。
	Duel.Release(tc,REASON_SPSUMMON)
end
-- ①效果的除外对象过滤函数：墓地中满足「宝玉兽」字段、攻击力大于0、且可以作为代价除外的怪兽。
function c37440988.cfilter(c)
	return c:IsSetCard(0x1034) and c:GetAttack()>0 and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：从自己墓地选择1只符合条件的「宝玉兽」怪兽除外，并把它的攻击力数值记录到 e 的标签中，供后续上升攻击力使用。
function c37440988.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认墓地有至少1只满足 cfilter 的「宝玉兽」怪兽可以除外，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37440988.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：‘请选择要除外的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地的符合条件的「宝玉兽」怪兽中选择1张作为除外的对象。
	local g=Duel.SelectMatchingCard(tp,c37440988.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片以表侧表示除外，原因为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetAttack())
end
-- ①效果处理：若这张卡仍在场上且表侧表示，且与发动效果关联，则给它注册一个攻击力上升的效果，上升值等于之前除外的怪兽的攻击力，直到回合结束。
function c37440988.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：这张卡必须以融合召唤方式成功召唤过（IsSummonType(SUMMON_TYPE_FUSION)）才能发动。
function c37440988.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ②效果的发动代价：解放这张卡自身（检查是否能解放，并执行解放）。
function c37440988.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放这张卡自身作为发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ②效果的目标：不取对象；确认场上存在至少1张（除自身外）可以返回持有者卡组的卡，并设置操作信息，将场上所有可回卡组的卡作为处理目标，回卡组数量为这些卡的总数。
function c37440988.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：确认场上存在至少1张除这张卡自身以外的、能返回持有者卡组的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 取得场上所有（双方怪兽区·魔陷区）能够返回持有者卡组的卡，作为效果处理的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将 g 中的卡全部返回持有者卡组，卡组数量为 g 的卡片数，分类为 CATEGORY_TODECK，以便外部效果（如星尘龙）正确响应。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：以处理时场上的实际卡片为准，将所有可以返回卡组的卡送回持有者卡组，并洗切卡组。
function c37440988.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取场上所有可返回持有者卡组的卡（因为处理时可能发生变化）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将 g 中的卡返回持有者卡组并洗切，返回原因记为效果（REASON_EFFECT）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
