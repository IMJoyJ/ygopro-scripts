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
	-- 注册卡名变更效果，使这张卡在场上·墓地存在时卡名当作「电子龙」使用。
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- 添加自定义活动计数器，用于记录玩家特殊召唤非机械族怪兽的次数。
	Duel.AddCustomActivityCounter(59281922,ACTIVITY_SPSUMMON,c59281922.counterfilter)
end
-- 计数器过滤函数，用于判定特殊召唤的怪兽是否为机械族。
function c59281922.counterfilter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 等级变化效果的Cost函数，用于检查并适用本回合不能特殊召唤非机械族怪兽的限制。
function c59281922.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否未曾特殊召唤过非机械族怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(59281922,tp,ACTIVITY_SPSUMMON)==0 end
	-- 自己场上的全部「电子龙」的等级变成5星。这个效果发动的回合，自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59281922.splimit)
	-- 注册不能特殊召唤非机械族怪兽的玩家效果（誓约限制）。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，判定非机械族怪兽不能特殊召唤。
function c59281922.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetRace()~=RACE_MACHINE
end
-- 过滤函数，用于筛选自己场上表侧表示的「电子龙」。
function c59281922.filter(c)
	return c:IsFaceup() and c:IsCode(70095154)
end
-- 等级变化效果的Target函数，检查场上是否存在可以改变等级的「电子龙」。
function c59281922.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「电子龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c59281922.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 等级变化效果的Operation函数，将自己场上全部「电子龙」的等级变成5星。
function c59281922.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「电子龙」卡片组。
	local g=Duel.GetMatchingGroup(c59281922.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「电子龙」的等级变成5星。
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
-- 被除外时赋予破坏耐性效果的Target函数，选择自己场上1只「电子龙」作为效果对象。
function c59281922.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c59281922.filter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示的「电子龙」。
	if chk==0 then return Duel.IsExistingTarget(c59281922.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择自己场上1只表侧表示的「电子龙」作为效果对象。
	Duel.SelectTarget(tp,c59281922.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 被除外时赋予破坏耐性效果的Operation函数，使作为对象的怪兽在这个回合不会被战斗·效果破坏。
function c59281922.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不会被战斗·效果破坏。
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
