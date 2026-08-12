--真竜の継承
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己抽出这个回合从场上送去墓地的「真龙」卡种类（怪兽·魔法·陷阱）的数量。
-- ②：自己主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c49430782.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己抽出这个回合从场上送去墓地的「真龙」卡种类（怪兽·魔法·陷阱）的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49430782,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,49430782)
	e2:SetCondition(c49430782.drcon)
	e2:SetTarget(c49430782.drtg)
	e2:SetOperation(c49430782.drop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49430782,1))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,49430783)
	e3:SetTarget(c49430782.sumtg)
	e3:SetOperation(c49430782.sumop)
	c:RegisterEffect(e3)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(49430782,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,49430784)
	e4:SetCondition(c49430782.descon)
	e4:SetTarget(c49430782.destg)
	e4:SetOperation(c49430782.desop)
	c:RegisterEffect(e4)
	if c49430782.counter==nil then
		c49430782.counter=0
		-- 记录场上送去墓地的真龙卡种类数量，用于效果①的抽卡次数计算
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c49430782.checkop)
		-- 注册场上的送去墓地事件监听器，用于统计真龙卡种类数量
		Duel.RegisterEffect(ge1,0)
		-- 注册回合开始时清空计数器的效果
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c49430782.clearop)
		-- 注册回合开始时清空计数器的效果
		Duel.RegisterEffect(ge2,0)
	end
end
-- 统计场上送去墓地的真龙卡种类并记录到counter变量中
function c49430782.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_ONFIELD) and tc:IsSetCard(0xf9) then
			local typ=bit.band(tc:GetOriginalType(),0x7)
			-- 判断是否为怪兽类型且未使用过效果①
			if (typ==TYPE_MONSTER and Duel.GetFlagEffect(0,49430782)==0)
				-- 判断是否为魔法类型且未使用过效果②
				or (typ==TYPE_SPELL and Duel.GetFlagEffect(0,49430783)==0)
				-- 判断是否为陷阱类型且未使用过效果③
				or (typ==TYPE_TRAP and Duel.GetFlagEffect(0,49430784)==0) then
				c49430782.counter=c49430782.counter+1
				if typ==TYPE_MONSTER then
					-- 注册效果①的使用标识，防止重复使用
					Duel.RegisterFlagEffect(0,49430782,RESET_PHASE+PHASE_END,0,1)
				elseif typ==TYPE_SPELL then
					-- 注册效果②的使用标识，防止重复使用
					Duel.RegisterFlagEffect(0,49430783,RESET_PHASE+PHASE_END,0,1)
				else
					-- 注册效果③的使用标识，防止重复使用
					Duel.RegisterFlagEffect(0,49430784,RESET_PHASE+PHASE_END,0,1)
				end
			end
		end
		tc=eg:GetNext()
	end
end
-- 回合开始时清空counter计数器
function c49430782.clearop(e,tp,eg,ep,ev,re,r,rp)
	c49430782.counter=0
end
-- 判断是否可以发动效果①（即是否有真龙卡送去墓地）
function c49430782.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c49430782.counter>0
end
-- 设置效果①的目标为抽卡，并检查是否可以抽卡
function c49430782.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,c49430782.counter) end
	-- 提示对方玩家选择了效果①
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c49430782.counter)
end
-- 执行效果①的抽卡操作
function c49430782.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际进行抽卡
	Duel.Draw(tp,c49430782.counter,REASON_EFFECT)
end
-- 定义用于上级召唤的真龙怪兽过滤函数
function c49430782.sumfilter(c)
	return c:IsSetCard(0xf9) and c:IsSummonable(true,nil,1)
end
-- 设置效果②的目标为上级召唤，并检查是否有符合条件的怪兽
function c49430782.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的真龙怪兽可以召唤
	if chk==0 then return Duel.IsExistingMatchingCard(c49430782.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示对方玩家选择了效果②
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为上级召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 执行效果②的上级召唤操作
function c49430782.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择符合条件的真龙怪兽进行召唤
	local g=Duel.SelectMatchingCard(tp,c49430782.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 实际进行上级召唤
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- 判断此卡是否从魔法与陷阱区域送去墓地
function c49430782.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 设置效果③的目标为破坏，并检查是否有符合条件的魔法或陷阱卡
function c49430782.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查是否有符合条件的魔法或陷阱卡可以破坏
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择符合条件的魔法或陷阱卡进行破坏
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果③的破坏操作
function c49430782.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 实际进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
