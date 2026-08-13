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
	-- 这张卡向对方怪兽攻击的战斗阶段结束时才能发动。场上1张卡除外。
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
	-- 自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
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
-- 定义特殊召唤素材的筛选条件：是「狱火机」系列怪兽且可被除外作为特殊召唤代价。
function c51316684.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义场上效果怪兽的筛选条件：表侧表示且为效果怪兽。
function c51316684.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 返回怪兽的等级或阶级：超量怪兽取阶级，其他取等级。
function c51316684.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 判断是否满足特殊召唤条件：自己场上效果怪兽的等级·阶级合计不超过8，且手卡/墓地中存在2只可除外的「狱火机」怪兽，并确保除外后仍有怪兽区空位。
function c51316684.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得自己场上表侧表示效果怪兽的等级/阶级合计值，用于判断是否在8以下。
	local sum=Duel.GetMatchingGroup(c51316684.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c51316684.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 取得可作为除外素材的「狱火机」怪兽集合，范围为手卡+墓地（若受特殊效果影响则还包括场上）。
	local g=Duel.GetMatchingGroup(c51316684.spfilter,tp,loc,0,c)
	-- 检查上述集合中是否存在2张卡，使得将它们除外后自己场上仍有可用怪兽区，以满足特殊召唤条件。
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 选择要除外的2只「狱火机」怪兽作为特殊召唤代价，保存到效果标签并返回是否可选。
function c51316684.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 取得可供选择作为特殊召唤除外素材的「狱火机」怪兽组，范围与条件判定一致。
	local g=Duel.GetMatchingGroup(c51316684.spfilter,tp,loc,0,c)
	-- 向玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从可选素材组中选择2张卡，并额外校验除外后自己场上仍有怪兽区空格。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤处理：取出之前保存的2只素材卡并将其除外，从而完成特殊召唤。
function c51316684.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的2只素材卡以表侧表示除外，作为特殊召唤的必需代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的发动条件：这张卡在己方回合的战斗阶段与对方怪兽进行过攻击后，该阶段结束时才能发动。
function c51316684.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是发动者回合且这张卡存在战斗过的对方怪兽（攻击过）。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetBattledGroup():GetCount()>0
end
-- ①效果发动时检查场上存在可以除外的卡，并设置除外1张卡的操作信息。
function c51316684.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上有至少1张可以除外的卡，作为①效果的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取得场上所有可以除外的卡，供效果处理时选择。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置本次连锁的处理信息：效果分类为除外，预计处理1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：从双方场上选择1张可以除外的卡并将其除外。
function c51316684.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从场上选择1张可以除外的卡（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡除外，处理原因为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的代价：解放自己场上1只怪兽。该函数同时负责检查和执行解放。
function c51316684.rmcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放所选怪兽，处理原因为代价。
	Duel.Release(g,REASON_COST)
end
-- ②效果发动时选择对象：以对方墓地1张卡为对象，检查合法性、选择对象并设置操作信息。
function c51316684.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可以作为对象的可除外卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1张可除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：将对方墓地1张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- ②效果处理：取得对象卡，若仍与效果关联则将其除外。
function c51316684.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡除外，处理原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
