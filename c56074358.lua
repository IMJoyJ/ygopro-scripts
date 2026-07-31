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
	-- ①：每次场上的怪兽表示形式变更，给这张卡放置1个变形斗士指示物。
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
	-- 攻击力提升对象过滤：场上的「变形斗士」怪兽
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
-- 攻击力上升数值计算：此卡的变形斗士指示物数量×300
function c56074358.atkval(e,c)
	return e:GetHandler():GetCounter(0x8)*300
end
-- 表示形式变更检测过滤：确认怪兽表示形式是否改变
function c56074358.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and ((np<3 and pp>3) or (pp<3 and np>3))
end
-- 放置指示物条件：存在表示形式变更的怪兽
function c56074358.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56074358.cfilter,1,nil)
end
-- 放置指示物处理：给此卡放置1个变形斗士指示物
function c56074358.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x8,1)
end
-- 墓地特召发动条件：场上的此卡被破坏送去墓地
function c56074358.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 墓地特召过滤条件：墓地的「变形斗士」怪兽且可特殊召唤
function c56074358.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地特召发动准备：选择墓地1只「变形斗士」怪兽为对象并设置特召操作信息
function c56074358.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56074358.filter(chkc,e,tp) end
	-- 发动条件检查：怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：墓地存在可特召的「变形斗士」怪兽
		and Duel.IsExistingTarget(c56074358.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只「变形斗士」怪兽作为对象
	local g=Duel.SelectTarget(tp,c56074358.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤对象怪兽1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 墓地特召效果处理：将对象怪兽表侧表示特殊召唤
function c56074358.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
