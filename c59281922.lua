--サイバー・ドラゴン・ドライ
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：这张卡召唤成功时才能发动。自己场上的全部「电子龙」的等级变成5星。这个效果发动的回合，自己不是机械族怪兽不能特殊召唤。
-- ③：这张卡被除外的场合，以自己场上1只「电子龙」为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏。
function c59281922.initial_effect(c)
	-- ②：这张卡召唤成功时才能发动。自己场上的全部「电子龙」的等级变成5星。这个效果发动的回合，自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59281922,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c59281922.lvcost)
	e1:SetTarget(c59281922.lvtg)
	e1:SetOperation(c59281922.lvop)
	c:RegisterEffect(e1)
	-- ③：这张卡被除外的场合，以自己场上1只「电子龙」为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59281922,1))  --"破坏耐性"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(c59281922.target)
	e2:SetOperation(c59281922.operation)
	c:RegisterEffect(e2)
	-- 在场上·墓地将卡名当作「电子龙」使用
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- 添加用于检测本回合是否特殊召唤了非机械族怪兽的计数器
	Duel.AddCustomActivityCounter(59281922,ACTIVITY_SPSUMMON,c59281922.counterfilter)
end
-- 检查特殊召唤的是否为表侧表示的机械族怪兽
function c59281922.counterfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 效果②的Cost与誓约限制：检查本回合至今特殊召唤非机械族怪兽的次数，并施加本回合不能特殊召唤非机械族怪兽的誓约
function c59281922.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否没有特殊召唤过非机械族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(59281922,tp,ACTIVITY_SPSUMMON)==0 end
	-- 自己场上的全部「电子龙」的等级变成5星。这个效果发动的回合，自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59281922.splimit)
	-- 注册不能特殊召唤非机械族怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制判定：不能特殊召唤非机械族怪兽
function c59281922.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetRace()~=RACE_MACHINE
end
-- 过滤条件：自己场上表侧表示的「电子龙」
function c59281922.filter(c)
	return c:IsFaceup() and c:IsCode(70095154)
end
-- 效果②的发动检测：确认自己场上是否存在表侧表示的「电子龙」
function c59281922.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的「电子龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c59281922.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的效果处理：将自己场上所有表侧表示的「电子龙」的等级变成5星
function c59281922.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的所有「电子龙」怪兽
	local g=Duel.GetMatchingGroup(c59281922.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「电子龙」的等级变成5星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 效果③的目标判定与选择：以自己场上1只「电子龙」为对象才能发动
function c59281922.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c59281922.filter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示的「电子龙」
	if chk==0 then return Duel.IsExistingTarget(c59281922.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「电子龙」作为效果对象
	Duel.SelectTarget(tp,c59281922.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的效果处理：使作为对象的怪兽在这个回合不会被战斗·效果破坏
function c59281922.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「电子龙」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不会被战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
