--究極宝玉神 レインボー・オーバー・ドラゴン
-- 效果：
-- 「宝玉兽」怪兽×7
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上1只10星「究极宝玉神」怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：1回合1次，从自己墓地把1只「宝玉兽」怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外的怪兽的攻击力数值。
-- ②：把融合召唤的这张卡解放才能发动。场上的卡全部回到持有者卡组。这个效果在对方回合也能发动。
function c37440988.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用7个满足条件的「宝玉兽」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1034),7,true)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡只能通过融合召唤特殊召唤
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
-- 定义特殊召唤时可选的解放对象过滤条件：必须是10星、控制者为玩家、有足够召唤空位、且能作为融合素材
function c37440988.hspfilter(c,tp,sc)
	-- 检查解放对象是否满足10星、控制者为玩家、有足够召唤空位
	return c:IsFusionSetCard(0x2034) and c:IsLevel(10) and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 检查玩家场上是否存在满足特殊召唤条件的解放对象
function c37440988.hspcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否存在满足特殊召唤条件的解放对象
	return Duel.CheckReleaseGroupEx(c:GetControler(),c37440988.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 选择并设置特殊召唤时要解放的卡
function c37440988.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡组中满足特殊召唤条件的卡
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c37440988.hspfilter,nil,tp,c)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c37440988.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 将指定卡从场上解放
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 定义攻击力提升效果的除外卡过滤条件：必须是「宝玉兽」、攻击力大于0、可作为除外费用
function c37440988.cfilter(c)
	return c:IsSetCard(0x1034) and c:GetAttack()>0 and c:IsAbleToRemoveAsCost()
end
-- 检查玩家墓地是否存在满足除外条件的卡并选择
function c37440988.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在满足除外条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37440988.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择玩家墓地中满足除外条件的卡
	local g=Duel.SelectMatchingCard(tp,c37440988.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为效果发动的费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetAttack())
end
-- 执行攻击力提升效果
function c37440988.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使该卡的攻击力提升指定数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否为融合召唤
function c37440988.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 判断该卡是否可被解放作为效果发动的费用
function c37440988.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将该卡从场上解放作为效果发动的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 准备发动“回到卡组”效果
function c37440988.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可送回卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有可送回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果发动时的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 执行“回到卡组”效果
function c37440988.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可送回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将指定卡送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
