--TG ハルバード・キャノン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：1回合1次，自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。这张卡在场上表侧表示存在的场合，那个无效，那些怪兽破坏。
-- ②：这张卡从场上送去墓地时，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽特殊召唤。
function c97836203.initial_effect(c)
	-- 设置同调召唤手续：同调怪兽调整+调整以外的同调怪兽2只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制这张卡只能通过同调召唤来特殊召唤
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。这张卡在场上表侧表示存在的场合，那个无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(97836203,0))  --"召唤无效并破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SUMMON)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c97836203.discon)
	e2:SetTarget(c97836203.distg)
	e2:SetOperation(c97836203.disop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(97836203,1))  --"反转召唤无效并破坏"
	e3:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(97836203,2))  --"特殊召唤无效并破坏"
	e4:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e4)
	-- ②：这张卡从场上送去墓地时，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(97836203,3))  --"特殊召唤"
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c97836203.spcon)
	e5:SetTarget(c97836203.sptg)
	e5:SetOperation(c97836203.spop)
	c:RegisterEffect(e5)
end
c97836203.material_type=TYPE_SYNCHRO
-- 召唤无效效果的发动条件判定函数
function c97836203.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前没有正在处理的连锁（即只能在不入连锁的召唤之际发动）
	return Duel.GetCurrentChain()==0
end
-- 召唤无效效果的发动目标判定与操作信息设置函数
function c97836203.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使即将召唤的怪兽的召唤无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏即将召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤无效效果的执行函数
function c97836203.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 使即将召唤的怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 因效果破坏那些召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件判定函数（必须从场上送去墓地）
function c97836203.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己墓地中可以特殊召唤的「科技属」怪兽
function c97836203.filter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 特殊召唤效果的发动目标判定与选择函数
function c97836203.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97836203.filter(chkc,e,tp) end
	-- 判定自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以特殊召唤的「科技属」怪兽
		and Duel.IsExistingTarget(c97836203.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「科技属」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97836203.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行函数
function c97836203.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP)
	end
end
