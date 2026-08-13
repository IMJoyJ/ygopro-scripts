--P・M・キャプチャー
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己对不死族怪兽的灵摆召唤成功时才能发动。那些怪兽在这个回合不会被战斗·效果破坏。
-- 【怪兽效果】
-- ①：这张卡战斗破坏怪兽的场合，以自己墓地1只灵摆怪兽为对象才能发动。那只怪兽加入手卡。
function c13760677.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：自己对不死族怪兽的灵摆召唤成功时才能发动。那些怪兽在这个回合不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13760677,0))  --"不会被战斗·效果破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c13760677.indcon)
	e2:SetTarget(c13760677.indtg)
	e2:SetOperation(c13760677.indop)
	c:RegisterEffect(e2)
	-- ①：这张卡战斗破坏怪兽的场合，以自己墓地1只灵摆怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13760677,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c13760677.thcon)
	e3:SetTarget(c13760677.thtg)
	e3:SetOperation(c13760677.thop)
	c:RegisterEffect(e3)
end
-- 筛选条件：c是不死族怪兽、由tp玩家灵摆召唤，并且（若传入效果e）与e仍有关联；用于筛选灵摆召唤成功的一组不死族怪兽。
function c13760677.cfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
		and (not e or c:IsRelateToEffect(e))
end
-- 触发条件：本次灵摆召唤成功的怪兽组eg中存在至少1只满足cfilter条件的不死族怪兽。
function c13760677.indcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13760677.cfilter,1,nil,nil,tp)
end
-- 发动时的目标处理：无需选择对象，直接允许发动，并将成功灵摆召唤的怪兽组eg设为效果对象。
function c13760677.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将eg中的全部怪兽设置为当前效果的处理对象，使这些怪兽与效果建立关联。
	Duel.SetTargetCard(eg)
end
-- 效果处理：从eg中筛选出仍与效果关联的不死族灵摆召唤怪兽，逐只赋予其在本回合内不会被战斗破坏和效果破坏的抗性。
function c13760677.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=eg:Filter(c13760677.cfilter,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽在这个回合不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 触发条件：这张卡在战斗破坏怪兽后仍与战斗相关，且被这张卡战斗破坏的对象是怪兽。
function c13760677.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 筛选对象：自己墓地中的灵摆怪兽，且该卡能够加入手卡。
function c13760677.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 取对象效果的目标处理：检查对象合法性，提示玩家从自己墓地选择1只灵摆怪兽，并设置操作信息为将其加入手卡。
function c13760677.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13760677.filter(chkc) end
	-- 效果发动合法性检查：自己墓地存在至少1只满足filter条件的灵摆怪兽。
	if chk==0 then return Duel.IsExistingTarget(c13760677.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张灵摆怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c13760677.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本连锁的操作信息：将选择的1张卡加入手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取回对象卡，若其仍与效果关联，则将其加入手卡。
function c13760677.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果处理时确定的对象卡（自己墓地选择的那只灵摆怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回其持有者的手卡，原因记为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
