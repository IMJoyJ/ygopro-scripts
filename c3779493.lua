--ナイトエンド・アドミニストレーター
-- 效果：
-- 「夜尽巫师」＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合或者自己场上有这张卡以外的魔法师族怪兽特殊召唤的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏的场合，以自己墓地1只4星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
function c3779493.initial_effect(c)
	-- 为这张怪兽卡登记同调素材卡名「夜尽巫师」（编号36107810），使相关卡名关联生效。
	aux.AddMaterialCodeList(c,36107810)
	-- 为这张卡设置同调召唤手续：调整必须为卡名「夜尽巫师」的怪兽，调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,36107810),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合或者自己场上有这张卡以外的魔法师族怪兽特殊召唤的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3779493,0))  --"对方墓地卡除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c3779493.target)
	e1:SetOperation(c3779493.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c3779493.condition)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：怪兽区域的这张卡被战斗或者对方的效果破坏的场合，以自己墓地1只4星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3779493,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,3779493)
	e3:SetCondition(c3779493.spcon)
	e3:SetTarget(c3779493.sptg)
	e3:SetOperation(c3779493.spop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：判断怪兽是否为表侧表示、由tp控制、魔法师族，用于检测特殊召唤成功的怪兽中是否有己方魔法师族怪兽。
function c3779493.cfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsFaceup() and c:IsControler(tp)
end
-- e2（①效果的另一触发分支）的发动条件：特殊召唤成功的一组怪兽中，存在1只自己控制的表侧表示魔法师族怪兽，且不是这张卡本身。
function c3779493.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c3779493.cfilter,1,e:GetHandler(),tp)
end
-- ①效果的目标选择处理：选择对方墓地1张可以除外的卡作为对象；进行发动合法性检查、提示选择、选择目标并设置除外操作信息。
function c3779493.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动时点检查：确认对方墓地存在至少1张可以被除外且能成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家显示选择提示消息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1张可以除外的卡作为效果对象，并自动与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置本次连锁的操作信息为：除外1张卡，用于其他卡对此效果的连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：取得对象卡，若该卡与效果仍有关联，则将其表侧表示除外。
function c3779493.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对方墓地对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以表侧表示将该对象卡除外，除外理由为效果处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡从怪兽区域被破坏，且破坏原因为对方的效果（并且破坏前控制者是tp）或被战斗破坏。
function c3779493.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and (rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) or c:IsReason(REASON_BATTLE))
end
-- ②效果的目标筛选：选择自己墓地1只4星以下、魔法师族、且满足特殊召唤条件与苏生限制的怪兽。
function c3779493.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择处理：检查自己怪兽区域有空格且墓地存在符合条件的魔法师族怪兽，选择其中1只作为对象，并设置特殊召唤操作信息。
function c3779493.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3779493.filter(chkc,e,tp) end
	-- 发动时点检查：确认自己场上主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时点检查：确认自己墓地存在至少1只符合条件的魔法师族怪兽可以作为特殊召唤的对象。
		and Duel.IsExistingTarget(c3779493.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示消息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的魔法师族怪兽作为效果对象，并自动与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,c3779493.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息为：特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得对象卡，若该卡与效果仍有关联，则将其特殊召唤到自己的怪兽区域。
function c3779493.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目的地墓地对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
