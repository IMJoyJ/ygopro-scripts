--異端なるフォボスコボス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以对方场上1只效果怪兽为对象才能发动（这张卡有幻想魔族怪兽在作为超量素材的场合，这个效果在对方回合也能发动）。作为对象的怪兽的效果无效。那只怪兽是这个回合已进行战斗的场合，可以再把那个控制权直到结束阶段得到。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含XYZ召唤手续、①效果的起动与即时效果版本注册、以及②效果的永续效果注册。
function s.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：以对方场上1只效果怪兽为对象才能发动（这张卡有幻想魔族怪兽在作为超量素材的场合，这个效果在对方回合也能发动）。作为对象的怪兽的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon1)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.discon2)
	c:RegisterEffect(e2)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判定超量素材中没有幻想魔族怪兽，作为①效果在自己回合作为起动效果发动的条件。
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_ILLUSION)
end
-- 判定超量素材中有幻想魔族怪兽，作为①效果在双方回合作为诱发即时效果发动的条件。
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_ILLUSION)
end
-- ①效果的对象选择与发动准备函数。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定选择的卡是否为合法的对方场上的效果怪兽对象。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateMonsterFilter(chkc) end
	-- 判定对方场上是否存在可以被无效效果的怪兽，用于效果发动的可行性检测。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端显示提示信息，要求玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果包含无效卡片效果的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果的实际处理函数，执行无效效果，并根据条件决定是否夺取控制权。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标怪兽相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 作为对象的怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 作为对象的怪兽的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 判定目标怪兽本回合是否进行过战斗、是否可以改变控制权，并询问玩家是否夺取控制权。
		if tc:GetBattledGroupCount()>0 and tc:IsControlerCanBeChanged() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否得到控制权？"
			-- 中断当前效果处理，使后续的夺取控制权处理与前面的无效效果不同时处理。
			Duel.BreakEffect()
			-- 夺取目标怪兽的控制权，直到结束阶段。
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	end
end
-- 确定不会被战斗破坏的怪兽范围，即这张卡自身以及与之进行战斗的怪兽。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
