--インフェルノイド・ルキフグス
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
-- ①：1回合1次，以场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c52038272.initial_effect(c)
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
	e2:SetCondition(c52038272.spcon)
	e2:SetTarget(c52038272.sptg)
	e2:SetOperation(c52038272.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52038272,0))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c52038272.descost)
	e3:SetTarget(c52038272.destg)
	e3:SetOperation(c52038272.desop)
	c:RegisterEffect(e3)
	-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52038272,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c52038272.rmcon)
	e4:SetCost(c52038272.rmcost)
	e4:SetTarget(c52038272.rmtg)
	e4:SetOperation(c52038272.rmop)
	c:RegisterEffect(e4)
end
-- 特殊召唤代价的过滤器：该卡必须是「狱火机」怪兽且可作为代价除外，同时除外后自己场上仍有可用怪兽区以进行特殊召唤。
function c52038272.spfilter(c,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确认将这张卡除外后，自己场上仍有可用的怪兽区域，从而保证能够从手卡特殊召唤到场上。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 筛选己方场上的表侧表示效果怪兽，用于计算其等级·阶级的合计值。
function c52038272.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 若怪兽为超量怪兽则取其阶级，否则取其等级；用于统一计算等级·阶级合计。
function c52038272.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤条件判定：自己场上表侧效果怪兽的等级·阶级合计在8以下，且手卡·墓地（若受特定效果影响则也包含场上）存在可作为代价除外的「狱火机」怪兽；c==nil 时表示规则询问，返回 true 由引擎继续判断。
function c52038272.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 计算己方场上所有表侧表示的效果怪兽的等级与阶级之和，作为特殊召唤条件的判定依据。
	local sum=Duel.GetMatchingGroup(c52038272.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c52038272.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 检查手卡·墓地（必要时包含场上）是否存在满足条件的「狱火机」怪兽可以作为除外代价，以确认特殊召唤规则可用。
	return Duel.IsExistingMatchingCard(c52038272.spfilter,tp,loc,0,1,c,tp)
end
-- 特殊召唤手续的目标选择阶段：从满足条件的「狱火机」怪兽中选择1只作为除外代价，并存入效果标签；选择成功则返回 true。
function c52038272.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取所有可作为特殊召唤除外代价的「狱火机」怪兽集合。
	local g=Duel.GetMatchingGroup(c52038272.spfilter,tp,loc,0,c,tp)
	-- 给玩家显示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理：先取出之前选择的除外对象，将其除外，然后由引擎完成从手卡的特殊召唤。
function c52038272.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的「狱火机」怪兽以表侧表示除外，原因为特殊召唤手续（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- ①效果的发动代价：确认本回合这张卡尚未进行过攻击宣言，然后给这张卡附加直到回合结束时不能攻击的效果。
function c52038272.descost(e,tp,eg,ep,ev,re,r,rp,chk)
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
-- ①效果的目标选择：取对象选择场上1只怪兽（双方怪兽区皆可），并设置破坏的操作信息。
function c52038272.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在至少1只可以作为对象选择的怪兽（包括里侧表示，因为破坏效果不要求表侧）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示‘请选择要破坏的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方怪兽区中的1只怪兽作为①效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁将破坏1只对象怪兽，用于连锁反应和效果无效判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：将对象怪兽破坏。
function c52038272.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前回合必须是对方回合。
function c52038272.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是自己，即满足‘对方回合’的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果的发动代价：解放自己场上的1只怪兽。先检查是否存在可解放怪兽，再选择并解放。
function c52038272.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以解放的怪兽作为代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放（REASON_COST），完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- ②效果的目标选择：以对方墓地1张卡为取对象目标，并设置除外操作信息。
function c52038272.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可以被除外的卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 给玩家显示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地中的1张卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：本次连锁将除外对方墓地1张卡，用于连锁反应和效果无效判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- ②效果处理：将对象卡除外。
function c52038272.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
