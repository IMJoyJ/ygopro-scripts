--守護天霊ロガエス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的天使族怪兽的效果发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：以对方场上1张表侧表示卡和自己场上1只攻击表示怪兽为对象才能发动。那张对方的卡除外，那只自己怪兽变成守备表示。
-- ③：场上的这张卡被战斗·效果破坏的场合，以场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗破坏。
function c84339249.initial_effect(c)
	-- ①：自己场上的天使族怪兽的效果发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84339249,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+84339249)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,84339249)
	e1:SetCondition(c84339249.spcon)
	e1:SetTarget(c84339249.sptg)
	e1:SetOperation(c84339249.spop)
	c:RegisterEffect(e1)
	-- ②：以对方场上1张表侧表示卡和自己场上1只攻击表示怪兽为对象才能发动。那张对方的卡除外，那只自己怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84339249,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,84339250)
	e2:SetTarget(c84339249.rmtg)
	e2:SetOperation(c84339249.rmop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合，以场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84339249,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c84339249.indcon)
	e3:SetTarget(c84339249.indtg)
	e3:SetOperation(c84339249.indop)
	c:RegisterEffect(e3)
	if not c84339249.global_check then
		c84339249.global_check=true
		-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的天使族怪兽的效果发动的场合才能发动。这张卡从手卡特殊召唤。②：以对方场上1张表侧表示卡和自己场上1只攻击表示怪兽为对象才能发动。那张对方的卡除外，那只自己怪兽变成守备表示。③：场上的这张卡被战斗·效果破坏的场合，以场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetCondition(c84339249.regcon)
		ge1:SetOperation(c84339249.regop)
		-- 注册全局环境效果，用于监听连锁处理结束的时点
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监听效果的发动条件：发动效果的是场上的天使族怪兽
function c84339249.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁的效果发动时的位置和种族
	local loc,race=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_RACE)
	return re:IsActiveType(TYPE_MONSTER) and loc&LOCATION_MZONE~=0 and race&RACE_FAIRY~=0
end
-- 全局监听效果的处理：触发自定义事件，用于手卡这张卡发动特殊召唤效果的时点
function c84339249.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，传入发动效果的怪兽和连锁相关参数
	Duel.RaiseEvent(re:GetHandler(),EVENT_CUSTOM+84339249,re,r,rp,ep,ev)
end
-- 特殊召唤效果的发动条件：发动天使族怪兽效果的玩家是自己
function c84339249.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
-- 特殊召唤效果的准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c84339249.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若这张卡仍在手卡，则将其表侧表示特殊召唤
function c84339249.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：对方场上表侧表示且可以被除外的卡
function c84339249.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 过滤条件：自己场上攻击表示且可以改变表示形式的怪兽
function c84339249.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 除外与改变表示形式效果的准备：选择对方场上1张表侧表示卡和自己场上1只攻击表示怪兽作为对象，并设置操作信息
function c84339249.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动准备阶段，检查对方场上是否存在可作为对象的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c84339249.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 同时检查自己场上是否存在可作为对象的攻击表示怪兽
		and Duel.IsExistingTarget(c84339249.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张表侧表示卡作为除外对象
	local g1=Duel.SelectTarget(tp,c84339249.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 选择自己场上1只攻击表示怪兽作为改变表示形式的对象
	local g2=Duel.SelectTarget(tp,c84339249.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为除外选中的对方卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,0,0)
	-- 设置当前连锁的操作信息为改变选中自己怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g2,1,0,0)
end
-- 除外与改变表示形式效果的处理：除外对方的对象卡，若成功除外，则将自己的对象怪兽变成守备表示
function c84339249.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁的所有对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp)
		-- 将对方的对象卡表侧表示除外，并确认其已成功移至除外区
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED)
		and lc:IsRelateToEffect(e) and lc:IsControler(tp) then
		-- 将自己的对象怪兽改变为守备表示
		Duel.ChangePosition(lc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
	end
end
-- 战斗破坏抗性效果的发动条件：场上的这张卡被战斗或效果破坏
function c84339249.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 战斗破坏抗性效果的准备：选择场上1只怪兽作为对象
function c84339249.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在效果发动准备阶段，检查场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择效果的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上任意1只怪兽作为对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 战斗破坏抗性效果的处理：给对象怪兽赋予本回合不会被战斗破坏的抗性
function c84339249.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
