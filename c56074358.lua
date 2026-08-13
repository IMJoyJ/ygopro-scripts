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
	-- 设定攻击力上升效果的作用对象为场上的「变形斗士」怪兽（卡名包含变形斗士的卡）。
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
c56074358.mentioned_counter={
	[0x8]=true,
}
-- 计算攻击力上升数值：这张卡的变形斗士指示物数量×300。
function c56074358.atkval(e,c)
	return e:GetHandler():GetCounter(0x8)*300
end
-- 过滤表示形式发生实质变更的怪兽：取当前表示形式与之前的表示形式，排除变更后又重新设为其他表示形式的情况，且要求当前与之前的表示形式一个在守备表示区域（数值小于3）、另一个在攻击表示区域（数值大于3），即确实发生了攻守表示形式的变更。
function c56074358.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and ((np<3 and pp>3) or (pp<3 and np>3))
end
-- 发动条件：本次表示形式变更事件中至少存在1只满足实质表示形式变更条件的怪兽。
function c56074358.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56074358.cfilter,1,nil)
end
-- 效果处理：给这张卡放置1个变形斗士指示物。
function c56074358.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x8,1)
end
-- 发动条件：这张卡因破坏被送去墓地，且之前位于场上。
function c56074358.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 对象过滤函数：自己墓地的「变形斗士」怪兽，且可以被特殊召唤。
function c56074358.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象目标函数：已选择的对象需在自己墓地且满足过滤条件；发动时点需确认自己主要怪兽区有空位，且自己墓地存在可作为对象的「变形斗士」怪兽。
function c56074358.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56074358.filter(chkc,e,tp) end
	-- 发动时点确认：自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时点确认：自己墓地存在1只以上可作为效果对象的特殊召唤可能的「变形斗士」怪兽。
		and Duel.IsExistingTarget(c56074358.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只满足条件的「变形斗士」怪兽为对象。
	local g=Duel.SelectTarget(tp,c56074358.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：本次效果将把对象的1只卡特殊召唤，供其他效果的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得作为对象的卡，若其仍与本效果关联，则将其以表侧表示特殊召唤到自己场上。
function c56074358.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的作为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
