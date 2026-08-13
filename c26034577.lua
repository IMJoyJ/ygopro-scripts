--インフェルノイド・ベルゼブル
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
-- ①：1回合1次，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c26034577.initial_effect(c)
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
	e2:SetCondition(c26034577.spcon)
	e2:SetTarget(c26034577.sptg)
	e2:SetOperation(c26034577.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26034577,0))  --"卡片回手"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c26034577.thtg)
	e3:SetOperation(c26034577.thop)
	c:RegisterEffect(e3)
	-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(26034577,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c26034577.rmcon)
	e4:SetCost(c26034577.rmcost)
	e4:SetTarget(c26034577.rmtg)
	e4:SetOperation(c26034577.rmop)
	c:RegisterEffect(e4)
end
-- 定义特殊召唤手续可除外的「狱火机」怪兽的筛选条件：必须是「狱火机」怪兽、可以作为除外代价除外，且除此外后自己场上仍有可用的怪兽区。
function c26034577.spfilter(c,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确保将该候选卡除外后自己场上仍有空余的怪兽区，即特殊召唤时有可用格子。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 筛选自己场上的表侧表示效果怪兽，用于后续计算等级·阶级合计。
function c26034577.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 取得怪兽的等级或阶级：超量怪兽取阶级，其余怪兽取等级，用于合计等级·阶级。
function c26034577.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤手续的发动条件：此卡在手牌；自己场上的表侧表示效果怪兽的等级·阶级合计不超过8；且在指定区域（手牌/墓地，若受特定效果影响也含场上）存在符合条件的「狱火机」怪兽可供除外。
function c26034577.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 计算自己场上所有表侧表示效果怪兽的等级·阶级合计值。
	local sum=Duel.GetMatchingGroup(c26034577.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c26034577.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 检查在指定区域是否存在至少1张满足可除外条件且除外后有空格的「狱火机」怪兽。
	return Duel.IsExistingMatchingCard(c26034577.spfilter,tp,loc,0,1,c,tp)
end
-- 特殊召唤手续的目标处理：从符合条件的「狱火机」怪兽中选择1张要除外的卡，存入效果标签，作为特殊召唤的代价；未选择则非法。
function c26034577.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取指定区域中所有满足可除外条件的「狱火机」怪兽集合。
	local g=Duel.GetMatchingGroup(c26034577.spfilter,tp,loc,0,c,tp)
	-- 显示“请选择要除外的卡”的选择提示，引导玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理：将选择好的「狱火机」怪兽除外，完成特殊召唤的代价处理，随后该卡从手卡特殊召唤。
function c26034577.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为特殊召唤代价的怪兽表侧表示除外，原因为特殊召唤。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 定义①效果可取对象条件：对方场上的表侧表示卡，且能够返回手卡。
function c26034577.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- ①效果的发动条件与对象选择：必须取对象为对方场上1张表侧表示且能回手卡的卡；发动时若不存在则不能发动；选择对象后登记回手牌操作。
function c26034577.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c26034577.thfilter(chkc) end
	-- 检查对方场上是否存在至少1张满足条件的表侧表示卡，以作为①效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c26034577.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要返回手牌的卡”的选择提示，用于选择①效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1张符合条件的表侧表示卡作为①效果的对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c26034577.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：本连锁会将该卡返回手牌（CATEGORY_TOHAND），供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：若对象卡片仍与效果关联，则将其返回持有者手牌。
function c26034577.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果当前处理的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者手牌，原因为效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前回合必须是对方回合。
function c26034577.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是此卡控制者，即满足“对方回合”条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果的发动代价：解放自己场上1只怪兽作为cost。
function c26034577.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将所选怪兽解放，原因为cost。
	Duel.Release(g,REASON_COST)
end
-- ②效果的发动条件与对象选择：取对象为对方墓地1张可除外的卡；发动时需存在对象；选择对象后登记除外操作信息。
function c26034577.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可以被除外的卡，以作为②效果的对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 显示“请选择要除外的卡”的选择提示，用于选择②效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1张可除外的卡作为②效果的对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 登记操作信息：本连锁会将该卡从对方墓地除外（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- ②效果处理：若对象卡仍与效果关联，则将其除外。
function c26034577.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果当前处理的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡表侧表示除外，原因为效果处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
