--革命の御旗
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡以外的自己场上的卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1张「自由解放」加入手卡。
-- ②：包含同调怪兽的怪兽之间进行战斗的伤害步骤开始时才能发动。那只进行战斗的对方怪兽破坏。
-- ③：魔法与陷阱区域的这张卡被效果破坏的场合，可以作为代替把自己场上1只怪兽破坏。
function c73193552.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡以外的自己场上的卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1张「自由解放」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73193552,0))  --"「自由解放」加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+73193552)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,73193552)
	e2:SetCondition(c73193552.condition)
	e2:SetTarget(c73193552.target)
	e2:SetOperation(c73193552.operation)
	c:RegisterEffect(e2)
	-- ②：包含同调怪兽的怪兽之间进行战斗的伤害步骤开始时才能发动。那只进行战斗的对方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73193552,1))  --"进行战斗的对方怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,73193553)
	e3:SetTarget(c73193552.atktg)
	e3:SetOperation(c73193552.atkop)
	c:RegisterEffect(e3)
	-- ③：魔法与陷阱区域的这张卡被效果破坏的场合，可以作为代替把自己场上1只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,73193554)
	e4:SetTarget(c73193552.desreptg)
	e4:SetOperation(c73193552.desrepop)
	c:RegisterEffect(e4)
	if not c73193552.global_check then
		c73193552.global_check=true
		-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡以外的自己场上的卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1张「自由解放」加入手卡。②：包含同调怪兽的怪兽之间进行战斗的伤害步骤开始时才能发动。那只进行战斗的对方怪兽破坏。③：魔法与陷阱区域的这张卡被效果破坏的场合，可以作为代替把自己场上1只怪兽破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c73193552.regcon)
		ge1:SetOperation(c73193552.regop)
		-- 注册全局环境的监听效果，用于检测场上卡片的破坏事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数：检查是否为自己场上因战斗或效果被破坏的卡
function c73193552.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 全局破坏事件的条件判断：检查是否有玩家场上的卡被破坏，并记录被破坏卡片的控制者
function c73193552.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c73193552.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c73193552.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局破坏事件的处理：触发自定义事件，向后续效果传递被破坏卡片的信息和控制者
function c73193552.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，将破坏的卡片组和控制者作为参数传递
	Duel.RaiseEvent(eg,EVENT_CUSTOM+73193552,re,r,rp,ep,e:GetLabel())
end
-- 效果①的发动条件：被破坏的卡片属于自己场上（控制者为自己或双方）
function c73193552.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 过滤函数：检查是否为卡名是「自由解放」且能加入手卡的卡
function c73193552.thfilter(c)
	return c:IsCode(72022087) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组或墓地是否存在「自由解放」，并设置检索/回收的操作信息
function c73193552.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己的卡组或墓地是否存在至少1张「自由解放」
	if chk==0 then return Duel.IsExistingMatchingCard(c73193552.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的效果处理：从卡组或墓地选择1张「自由解放」加入手卡，并给对方确认
function c73193552.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张「自由解放」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c73193552.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动准备：检查进行战斗的怪兽中是否包含同调怪兽，并设置破坏对方怪兽的操作信息
function c73193552.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行战斗的自己怪兽和对方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	if chk==0 then return a and d and (a:IsFaceup() and a:IsType(TYPE_SYNCHRO) or d:IsFaceup() and d:IsType(TYPE_SYNCHRO)) end
	-- 设置操作信息：破坏进行战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 效果②的效果处理：将进行战斗的对方怪兽破坏
function c73193552.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行战斗的自己怪兽和对方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	if d and d:IsRelateToBattle() then
		-- 因效果破坏进行战斗的对方怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 过滤函数：检查是否为自己场上可以被效果破坏、且未确定被破坏的怪兽
function c73193552.repfilter(c,e)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 效果③的代替破坏准备：检查自身是否因效果被破坏，以及自己场上是否存在可代替破坏的怪兽，并询问玩家是否发动
function c73193552.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:IsFaceup()
		-- 检查自己场上是否存在至少1只可以代替破坏的怪兽
		and Duel.IsExistingMatchingCard(c73193552.repfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 向玩家提示选择要代替破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择自己场上的1只怪兽作为代替破坏的对象
		local g=Duel.SelectMatchingCard(tp,c73193552.repfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
		e:SetLabelObject(g:GetFirst())
		-- 在场上显式框选被选为代替破坏的怪兽
		Duel.HintSelection(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 效果③的代替破坏处理：将选中的代替怪兽破坏，从而使这张卡免于被破坏
function c73193552.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的怪兽作为代替破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
