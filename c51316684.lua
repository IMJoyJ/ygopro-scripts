--インフェルノイド・ヴァエル
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地2只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
-- ①：这张卡向对方怪兽攻击的战斗阶段结束时才能发动。场上1张卡除外。
-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c51316684.initial_effect(c)
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
	e2:SetCondition(c51316684.spcon)
	e2:SetTarget(c51316684.sptg)
	e2:SetOperation(c51316684.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡向对方怪兽攻击的战斗阶段结束时才能发动。场上1张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51316684,0))  --"场上的卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c51316684.rmcon)
	e3:SetTarget(c51316684.rmtg)
	e3:SetOperation(c51316684.rmop)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(51316684,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c51316684.rmcost2)
	e4:SetTarget(c51316684.rmtg2)
	e4:SetOperation(c51316684.rmop2)
	c:RegisterEffect(e4)
end
-- 过滤满足「狱火机」字段、怪兽类型、可作为除外费用的卡片。
function c51316684.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤场上表侧表示的效果怪兽。
function c51316684.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级，用于计算总和。
function c51316684.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 检查场上效果怪兽的等级·阶级合计是否不超过8，并确认是否有满足条件的2只「狱火机」怪兽可除外。
function c51316684.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有效果怪兽的等级或阶级总和。
	local sum=Duel.GetMatchingGroup(c51316684.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c51316684.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c51316684.spfilter,tp,loc,0,c)
	-- 检查是否存在满足条件的2只怪兽组合。
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 选择并设置要除外的2只「狱火机」怪兽。
function c51316684.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组。
	local g=Duel.GetMatchingGroup(c51316684.spfilter,tp,loc,0,c)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的怪兽中选择2只组成组合。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时将选定的怪兽除外。
function c51316684.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡片以除外形式移除。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否为战斗阶段结束且已攻击过对方怪兽。
function c51316684.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于控制者，并且该卡已参与战斗。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetBattledGroup():GetCount()>0
end
-- 设置效果发动时的目标选择条件。
function c51316684.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可除外的场上卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取所有可除外的场上卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息为除外效果。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 选择并执行除外场上一张卡的操作。
function c51316684.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从场上选择一张可除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 将指定的卡片以除外形式移除。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 设置效果发动时的费用支付条件。
function c51316684.rmcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放1只怪兽作为费用。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择要解放的1只怪兽。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选定的怪兽进行解放操作。
	Duel.Release(g,REASON_COST)
end
-- 设置效果发动时的目标选择条件。
function c51316684.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否存在对方墓地可除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地中选择1张可除外的卡作为目标。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息为除外效果。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 执行将目标卡除外的操作。
function c51316684.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将指定的目标卡以除外形式移除。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
