--D・フィールド
-- 效果：
-- ①：每次场上的怪兽的表示形式变更，给这张卡放置1个变形斗士指示物。
-- ②：场上的「变形斗士」怪兽的攻击力上升这张卡的变形斗士指示物数量×300。
-- ③：场上的这张卡被破坏送去墓地时，以自己墓地1只「变形斗士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c56074358.initial_effect(c)
	c:EnableCounterPermit(0x8)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次场上的怪兽的表示形式变更，给这张卡放置1个变形斗士指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c56074358.accon)
	e2:SetOperation(c56074358.acop)
	c:RegisterEffect(e2)
	-- ②：场上的「变形斗士」怪兽的攻击力上升这张卡的变形斗士指示物数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤受攻击力上升效果影响的卡片为「变形斗士」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x26))
	e3:SetValue(c56074358.atkval)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被破坏送去墓地时，以自己墓地1只「变形斗士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(56074358,0))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c56074358.spcon)
	e4:SetTarget(c56074358.sptg)
	e4:SetOperation(c56074358.spop)
	c:RegisterEffect(e4)
end
-- 计算攻击力上升的数值，为这张卡上的变形斗士指示物数量×300
function c56074358.atkval(e,c)
	return e:GetHandler():GetCounter(0x8)*300
end
-- 过滤表示形式变更的怪兽，判定其是否在攻击表示与守备表示之间进行了切换
function c56074358.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and ((np<3 and pp>3) or (pp<3 and np>3))
end
-- 判定场上是否存在表示形式变更的怪兽
function c56074358.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56074358.cfilter,1,nil)
end
-- 给这张卡放置1个变形斗士指示物
function c56074358.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x8,1)
end
-- 判定发动条件：这张卡在场上被破坏并送去墓地
function c56074358.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己墓地中可以特殊召唤的「变形斗士」怪兽
function c56074358.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与合法性检测，判定墓地是否存在可特殊召唤的「变形斗士」怪兽且自己场上有空位
function c56074358.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56074358.filter(chkc,e,tp) end
	-- 判定自己场上是否有可以特殊召唤怪兽的空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以作为效果对象的「变形斗士」怪兽
		and Duel.IsExistingTarget(c56074358.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「变形斗士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56074358.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，该效果包含特殊召唤分类，操作对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽在自己场上特殊召唤
function c56074358.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
