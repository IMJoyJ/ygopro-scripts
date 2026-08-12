--地縛牢
-- 效果：
-- ①：这张卡的发动时，可以以对方场上1只效果怪兽为对象。那个场合，这张卡得到以下效果。
-- ●只要这张卡在场地区域存在，作为对象的效果怪兽的效果无效化。
-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「地缚」怪兽召唤。
-- ③：这张卡被对方的效果破坏的场合，若自己的场上或墓地有「地缚」怪兽存在则发动。对方基本分变成一半，对方场上的全部表侧表示卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、无效化对象怪兽、追加召唤「地缚」怪兽以及被破坏时的诱发效果。
function s.initial_effect(c)
	-- ①：这张卡的发动时，可以以对方场上1只效果怪兽为对象。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(s.distg)
	c:RegisterEffect(e0)
	-- ●只要这张卡在场地区域存在，作为对象的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TARGET)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e1)
	-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「地缚」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"使用「地缚牢」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置追加召唤的效果目标为「地缚」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x21))
	c:RegisterEffect(e2)
	-- ③：这张卡被对方的效果破坏的场合，若自己的场上或墓地有「地缚」怪兽存在则发动。对方基本分变成一半，对方场上的全部表侧表示卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.hlpcon)
	e3:SetTarget(s.hlptg)
	e3:SetOperation(s.hlpop)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果处理目标判定，若玩家选择以对方怪兽为对象，则进行取对象操作并设置无效化操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 进行效果对象的合法性检查，对象必须是对方场上未被无效的效果怪兽。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	if chk==0 then return true end
	-- 检查对方场上是否存在至少1只未被无效的效果怪兽。
	if Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否在发动时选择对方场上的1只效果怪兽作为对象。
		and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2)) then  --"是否以对方怪兽为对象发动？"
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.disop)
		-- 向玩家发送选择要无效的卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择对方场上1只未被无效的效果怪兽作为效果对象。
		local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置连锁的操作信息，表示该效果包含使1张卡效果无效的操作。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 卡片发动时的效果处理，若成功选择了对象，则将该卡与对象怪兽建立持续的取对象连接。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then c:SetCardTarget(tc) end
end
-- 筛选自己场上或墓地表侧表示的「地缚」怪兽。
function s.filter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x21) and c:IsType(TYPE_MONSTER)
end
-- 判定效果③的发动条件，即这张卡在己方场上被对方的效果破坏。
function s.hlpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 效果③的目标判定，检查自己场上或墓地是否有「地缚」怪兽，并设置无效化对方场上所有表侧表示卡的操作信息。
function s.hlptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己的场上或墓地是否存在「地缚」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	-- 获取对方场上所有可以被无效的表侧表示卡片。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息，表示该效果包含使对方场上所有表侧表示卡效果无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- 效果③的效果处理，将对方基本分变成一半，并使对方场上全部表侧表示卡的效果直到回合结束时无效。
function s.hlpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家的当前基本分。
	local lp=Duel.GetLP(1-tp)
	-- 将对方玩家的基本分变成一半（向上取整）。
	Duel.SetLP(1-tp,math.ceil(lp/2))
	local c=e:GetHandler()
	-- 获取对方场上所有可以被无效的表侧表示卡片组。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 遍历对方场上所有符合条件的表侧表示卡片。
	for tc in aux.Next(g) do
		-- 对方场上的全部表侧表示卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end
end
