--ナイトエンド・アドミニストレーター
-- 效果：
-- 「夜尽巫师」＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合或者自己场上有这张卡以外的魔法师族怪兽特殊召唤的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏的场合，以自己墓地1只4星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
function c3779493.initial_effect(c)
	-- 为该怪兽添加融合召唤所需的素材代码列表，允许使用卡号为36107810的卡作为素材
	aux.AddMaterialCodeList(c,36107810)
	-- 设置该怪兽的同调召唤手续，要求1只卡号为36107810的调整，以及1只调整以外的怪兽作为同调素材
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
	-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏的场合，以自己墓地1只4星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 用于判断场上是否存在己方的魔法师族怪兽（正面表示且控制者为tp）
function c3779493.cfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsFaceup() and c:IsControler(tp)
end
-- 判断是否满足效果①的触发条件，即是否有己方的魔法师族怪兽（除自身外）被特殊召唤
function c3779493.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c3779493.cfilter,1,e:GetHandler(),tp)
end
-- 设置效果①的目标选择函数，用于选择对方墓地的一张可除外的卡
function c3779493.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否满足效果①的发动条件，即对方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地的一张可除外的卡作为效果①的目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果①的连锁操作信息，指定将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果①的操作，将目标卡除外
function c3779493.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断效果②是否满足发动条件，即该卡是否被战斗或对方效果破坏且在己方场上
function c3779493.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and (rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) or c:IsReason(REASON_BATTLE))
end
-- 用于筛选墓地中满足条件的魔法师族怪兽（等级不超过4星）
function c3779493.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果②的目标选择函数，用于选择己方墓地中满足条件的魔法师族怪兽
function c3779493.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3779493.filter(chkc,e,tp) end
	-- 检查是否满足效果②的发动条件，即己方场上是否有空位且己方墓地存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地是否存在满足条件的魔法师族怪兽
		and Duel.IsExistingTarget(c3779493.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择己方墓地中满足条件的魔法师族怪兽作为效果②的目标
	local g=Duel.SelectTarget(tp,c3779493.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果②的连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果②的操作，将目标怪兽特殊召唤
function c3779493.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以特殊召唤方式召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
