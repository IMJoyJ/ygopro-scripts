--インフェルノイド・シャイターン
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
-- ①：1回合1次，以场上1张里侧表示卡为对象才能发动（不能对应这个效果的发动把作为对象的魔法·陷阱卡发动）。那张卡回到卡组。
-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c60551528.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c60551528.spcon)
	e2:SetTarget(c60551528.sptg)
	e2:SetOperation(c60551528.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以场上1张里侧表示卡为对象才能发动（不能对应这个效果的发动把作为对象的魔法·陷阱卡发动）。那张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c60551528.tdtg)
	e3:SetOperation(c60551528.tdop)
	c:RegisterEffect(e3)
	-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c60551528.rmcon)
	e4:SetCost(c60551528.rmcost)
	e4:SetTarget(c60551528.rmtg)
	e4:SetOperation(c60551528.rmop)
	c:RegisterEffect(e4)
end
-- 特殊召唤条件的过滤函数：选择手卡·墓地（或场上）的「狱火机」怪兽，且该卡除外后能腾出足够的怪兽区域
function c60551528.spfilter(c,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查将该卡作为Cost除外后，自己场上是否有可用的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤场上的表侧表示效果怪兽
function c60551528.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级（超量怪兽返回阶级，其他怪兽返回等级）
function c60551528.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤规则的条件判定：计算场上效果怪兽的等级·阶级合计，并确认是否存在可作为Cost除外的「狱火机」怪兽
function c60551528.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 计算自己场上所有表侧表示效果怪兽的等级·阶级合计值
	local sum=Duel.GetMatchingGroup(c60551528.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c60551528.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 检查指定位置是否存在至少1只满足特殊召唤Cost条件的「狱火机」怪兽
	return Duel.IsExistingMatchingCard(c60551528.spfilter,tp,loc,0,1,c,tp)
end
-- 特殊召唤规则的Cost选择：让玩家选择1只用于除外的「狱火机」怪兽，并将其保存在LabelObject中
function c60551528.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取所有可作为特殊召唤Cost除外的「狱火机」怪兽组
	local g=Duel.GetMatchingGroup(c60551528.spfilter,tp,loc,0,c,tp)
	-- 向玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的Cost执行：除外选中的「狱火机」怪兽
function c60551528.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤Cost为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤场上的里侧表示且能回到卡组的卡
function c60551528.tdfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 效果①的靶向与发动准备：选择场上1张里侧表示卡为对象，设置操作信息，并限制对方不能对应此效果发动该对象魔陷
function c60551528.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c60551528.tdfilter(chkc) end
	-- 发动准备阶段：检查场上是否存在可以作为对象的里侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c60551528.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张里侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c60551528.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设定连锁限制：不能对应这个效果的发动把作为对象的魔法·陷阱卡发动
	Duel.SetChainLimit(c60551528.limit(g:GetFirst()))
end
-- 效果①的效果处理：将作为对象的卡回到持有者卡组并洗牌
function c60551528.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 连锁限制的判定函数：如果连锁发动的卡是当前作为对象的卡，则不允许发动
function c60551528.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 效果②的发动条件：只能在对方回合发动
function c60551528.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的Cost处理：解放自己场上1只怪兽
function c60551528.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查阶段：检查自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选中的怪兽作为发动Cost
	Duel.Release(g,REASON_COST)
end
-- 效果②的靶向与发动准备：选择对方墓地1张卡为对象，并设置除外操作信息
function c60551528.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动准备阶段：检查对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：除外对方墓地的目标卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：将作为对象的对方墓地的卡除外
function c60551528.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
