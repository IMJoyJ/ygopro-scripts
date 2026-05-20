--DDプラウド・オーガ
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，支付500基本分，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的攻击力上升500。
-- ②：另一边的自己的灵摆区域没有「DD」卡存在的场合，这张卡的灵摆刻度变成5。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。从自己的额外卡组把1只表侧表示的暗属性灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
function c81571633.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，支付500基本分，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81571633,0))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c81571633.atkcost)
	e2:SetTarget(c81571633.atktg)
	e2:SetOperation(c81571633.atkop)
	c:RegisterEffect(e2)
	-- ②：另一边的自己的灵摆区域没有「DD」卡存在的场合，这张卡的灵摆刻度变成5。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_LSCALE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c81571633.sccon)
	e3:SetValue(5)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e4)
	-- ①：这张卡召唤成功时才能发动。从自己的额外卡组把1只表侧表示的暗属性灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(81571633,1))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(c81571633.sptg)
	e5:SetOperation(c81571633.spop)
	c:RegisterEffect(e5)
end
-- 灵摆效果①的Cost（支付基本分）判定与执行函数。
function c81571633.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 过滤自己场上表侧表示的「DD」怪兽。
function c81571633.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 灵摆效果①的对象选择与发动准备函数。
function c81571633.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c81571633.atkfilter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的「DD」怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c81571633.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「DD」怪兽作为效果对象。
	Duel.SelectTarget(tp,c81571633.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果①的效果处理（增加攻击力）函数。
function c81571633.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 灵摆效果②的生效条件判定函数。
function c81571633.sccon(e)
	-- 检查另一边的灵摆区域是否存在除自身以外的「DD」卡，若不存在则返回true。
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0xaf)
end
-- 过滤额外卡组中表侧表示、可特殊召唤的暗属性灵摆怪兽，并检查额外怪兽区域/连接端是否有空位。
function c81571633.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查该卡是否能被特殊召唤，且额外卡组怪兽出场所需的怪兽区域是否有空位。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 怪兽效果①的发动准备与特殊召唤信息注册函数。
function c81571633.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只符合特殊召唤条件的暗属性灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c81571633.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 注册连锁信息，表明该效果包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的效果处理（特殊召唤、效果无效化及后续特殊召唤限制）函数。
function c81571633.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取额外卡组中所有符合特殊召唤条件的暗属性灵摆怪兽。
	local g=Duel.GetMatchingGroup(c81571633.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选中的怪兽以表侧表示特殊召唤到场上（分步处理）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤的最终处理。
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c81571633.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤「DD」以外怪兽的限制效果注册给玩家。
	Duel.RegisterEffect(e3,tp)
end
-- 限制只能特殊召唤「DD」怪兽的过滤函数。
function c81571633.splimit(e,c)
	return not c:IsSetCard(0xaf)
end
