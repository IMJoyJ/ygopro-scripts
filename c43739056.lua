--天孔邪鬼
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己不能把这张卡以外的和这张卡相同属性的特殊召唤的怪兽的效果发动。
-- ②：1回合1次，自己·对方的主要阶段才能发动。这张卡的控制权移给对方。那之后，可以把这张卡的属性直到下个回合的结束时变更为任意属性。这个效果不在这张卡的原本持有者的回合不能发动。
function c43739056.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己不能把这张卡以外的和这张卡相同属性的特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c43739056.actlimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己·对方的主要阶段才能发动。这张卡的控制权移给对方。那之后，可以把这张卡的属性直到下个回合的结束时变更为任意属性。这个效果不在这张卡的原本持有者的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43739056,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c43739056.ctcon)
	e2:SetTarget(c43739056.cttg)
	e2:SetOperation(c43739056.ctop)
	c:RegisterEffect(e2)
end
-- 该效果限制了当怪兽特殊召唤时，若其属性与天孔邪鬼相同，则不能发动其效果。
function c43739056.actlimit(e,re,tp)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and re:GetActivateLocation()==LOCATION_MZONE
		and rc:IsAttribute(c:GetAttribute()) and rc~=c and tp==c:GetControler()
end
-- 判断是否满足效果发动条件：当前回合玩家为天孔邪鬼的原持有者，且当前阶段为主要阶段1或主要阶段2。
function c43739056.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	-- 判断当前回合玩家是否为天孔邪鬼的原持有者，并且当前阶段是否为主要阶段1或主要阶段2。
	return p==Duel.GetTurnPlayer() and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 设置发动时的操作信息，表示将要改变控制权。
function c43739056.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged() end
	-- 设置操作信息，表示将要改变控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 执行控制权转移和属性变更效果，包括判断是否可以改变控制权、询问是否变更属性、宣言属性并设置属性变更效果。
function c43739056.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断天孔邪鬼是否仍然在场上、是否成功转移控制权，并询问玩家是否要变更属性。
	if c:IsRelateToEffect(e) and Duel.GetControl(c,1-tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(43739056,0)) then  --"是否改变属性？"
		-- 中断当前效果处理，防止后续效果同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要宣言的属性。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让玩家从可选属性中宣言一个属性（不包括当前属性）。
		local aat=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
		-- 将天孔邪鬼的属性在下个回合结束前变更为宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(aat)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
