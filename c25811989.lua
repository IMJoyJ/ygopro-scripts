--インフェルノイド・アシュメダイ
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地2只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
-- ①：这张卡向对方怪兽的攻击给与对方战斗伤害时才能发动。对方手卡随机1张送去墓地。
-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c25811989.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地2只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c25811989.spcon)
	e2:SetTarget(c25811989.sptg)
	e2:SetOperation(c25811989.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡向对方怪兽的攻击给与对方战斗伤害时才能发动。对方手卡随机1张送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25811989,0))  --"手卡破坏"
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c25811989.thcon)
	e3:SetTarget(c25811989.thtg)
	e3:SetOperation(c25811989.thop)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25811989,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c25811989.rmcost)
	e4:SetTarget(c25811989.rmtg)
	e4:SetOperation(c25811989.rmop)
	c:RegisterEffect(e4)
end
-- 过滤满足「狱火机」字段、怪兽类型、可作为除外费用的卡片。
function c25811989.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤场上表侧表示的效果怪兽。
function c25811989.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级。
function c25811989.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 检查场上效果怪兽的等级·阶级合计是否不超过8，并确认手卡·墓地是否有2只满足条件的「狱火机」怪兽。
function c25811989.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有效果怪兽的等级或阶级总和。
	local sum=Duel.GetMatchingGroup(c25811989.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c25811989.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c25811989.spfilter,tp,loc,0,c)
	-- 检查是否能选出2只满足条件的怪兽并确保怪兽区有足够空位。
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 选择2只满足条件的「狱火机」怪兽并设置为特殊召唤的除外对象。
function c25811989.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c25811989.spfilter,tp,loc,0,c)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从满足条件的怪兽组中选择2只并确保怪兽区有足够空位。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选择的2只怪兽除外，完成特殊召唤。
function c25811989.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否为对方造成的战斗伤害且攻击怪兽为目标怪兽。
function c25811989.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方造成的战斗伤害且攻击怪兽为目标怪兽。
	return ep~=tp and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
-- 设置效果处理时要丢弃对方手牌。
function c25811989.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置效果处理时要丢弃对方手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 随机选择对方1张手牌并送去墓地。
function c25811989.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方所有手牌。
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	local sg=g:RandomSelect(ep,1)
	-- 将指定的卡送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
-- 设置解放1只怪兽作为费用。
function c25811989.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能解放1只怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择1只可解放的怪兽。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放指定的怪兽。
	Duel.Release(g,REASON_COST)
end
-- 设置选择对方墓地1张卡作为除外对象。
function c25811989.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可除外的卡。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理时要除外对方墓地的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 将指定的对方墓地卡除外。
function c25811989.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将指定的卡除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
