--インフェルノイド・アスタロス
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
-- ①：1回合1次，以场上1张魔法·陷阱卡为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那张卡破坏。
-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c89423971.initial_effect(c)
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
	e2:SetCondition(c89423971.spcon)
	e2:SetTarget(c89423971.sptg)
	e2:SetOperation(c89423971.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以场上1张魔法·陷阱卡为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89423971,0))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c89423971.descost)
	e3:SetTarget(c89423971.destg)
	e3:SetOperation(c89423971.desop)
	c:RegisterEffect(e3)
	-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(89423971,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c89423971.rmcon)
	e4:SetCost(c89423971.rmcost)
	e4:SetTarget(c89423971.rmtg)
	e4:SetOperation(c89423971.rmop)
	c:RegisterEffect(e4)
end
-- 过滤手牌或墓地中可作为特殊召唤Cost除外的「狱火机」怪兽
function c89423971.spfilter(c,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查将该卡除外作为Cost后，是否能空出可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤场上表侧表示的效果怪兽
function c89423971.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级（超量怪兽返回阶级，其他怪兽返回等级）
function c89423971.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤规则的条件判定函数
function c89423971.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 计算自己场上所有表侧表示效果怪兽的等级·阶级合计值
	local sum=Duel.GetMatchingGroup(c89423971.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c89423971.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 检查手牌或墓地是否存在可作为Cost除外的「狱火机」怪兽
	return Duel.IsExistingMatchingCard(c89423971.spfilter,tp,loc,0,1,c,tp)
end
-- 特殊召唤规则的Cost选择阶段
function c89423971.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取手牌或墓地中所有可作为Cost除外的「狱火机」怪兽组
	local g=Duel.GetMatchingGroup(c89423971.spfilter,tp,loc,0,c,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行阶段
function c89423971.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的「狱火机」怪兽因特殊召唤Cost而表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤魔法·陷阱卡
function c89423971.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动Cost判定与执行
function c89423971.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- （这个效果发动的回合，这张卡不能攻击）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 破坏效果的对象选择与效果信息注册
function c89423971.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c89423971.filter(chkc) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c89423971.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c89423971.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数
function c89423971.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 除外效果的发动条件判定（仅在对方回合可以发动）
function c89423971.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 除外效果的发动Cost判定与执行
function c89423971.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放Cost
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选定的怪兽
	Duel.Release(g,REASON_COST)
end
-- 除外效果的对象选择与效果信息注册
function c89423971.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为除外选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 除外效果的执行函数
function c89423971.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
