--P・M・キャプチャー
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己对不死族怪兽的灵摆召唤成功时才能发动。那些怪兽在这个回合不会被战斗·效果破坏。
-- 【怪兽效果】
-- ①：这张卡战斗破坏怪兽的场合，以自己墓地1只灵摆怪兽为对象才能发动。那只怪兽加入手卡。
function c13760677.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
-- 过滤满足条件的怪兽（不死族、灵摆召唤、属于玩家）
function c13760677.cfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
		and (not e or c:IsRelateToEffect(e))
end
-- 判断是否有满足条件的怪兽被灵摆召唤成功
function c13760677.indcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13760677.cfilter,1,nil,nil,tp)
end
-- 设置效果目标为被灵摆召唤成功的怪兽
function c13760677.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁对象设置为被灵摆召唤成功的怪兽
	Duel.SetTargetCard(eg)
end
-- 处理效果的执行函数，为符合条件的怪兽添加不被破坏的效果
function c13760677.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=eg:Filter(c13760677.cfilter,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽添加不会被战斗破坏的效果
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
-- 判断此卡是否参与了战斗并破坏了对方怪兽
function c13760677.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 过滤墓地中的灵摆怪兽
function c13760677.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置效果目标为墓地中的灵摆怪兽
function c13760677.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13760677.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c13760677.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择墓地中的1只灵摆怪兽作为目标
	local g=Duel.SelectTarget(tp,c13760677.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将要将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的执行函数，将目标卡加入手牌
function c13760677.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
