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
		-- ①：自己主要阶段才能发动。自己抽出这个回合从场上送去墓地的「真龙」卡种类（怪兽·魔法·陷阱）的数量。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c49430782.checkop)
		-- 将监测卡牌被送去墓地的全局持续效果注册到游戏中，用于统计本回合从场上送去墓地的「真龙」卡种类。
		Duel.RegisterEffect(ge1,0)
		-- ①：自己主要阶段才能发动。自己抽出这个回合从场上送去墓地的「真龙」卡种类（怪兽·魔法·陷阱）的数量。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c49430782.clearop)
		-- 注册在抽卡阶段开始时将真龙卡种类计数器清零的全局效果，使统计仅限当前回合。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当有卡被送去墓地时，检测其是否为从场上送去的「真龙」卡；若是，则根据其种类（怪兽/魔法/陷阱）进行去重计数，记录本回合的真龙卡种类。
function c49430782.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_ONFIELD) and tc:IsSetCard(0xf9) then
			local typ=bit.band(tc:GetOriginalType(),0x7)
			-- 判断该「真龙」卡是否为怪兽种类，且本回合尚未记录过怪兽种类，避免重复计数。
			if (typ==TYPE_MONSTER and Duel.GetFlagEffect(0,49430782)==0)
				-- 判断该「真龙」卡是否为魔法种类，且本回合尚未记录过魔法种类，避免重复计数。
				or (typ==TYPE_SPELL and Duel.GetFlagEffect(0,49430783)==0)
				-- 判断该「真龙」卡是否为陷阱种类，且本回合尚未记录过陷阱种类；满足任一条件则进入计数分支。
				or (typ==TYPE_TRAP and Duel.GetFlagEffect(0,49430784)==0) then
				c49430782.counter=c49430782.counter+1
				if typ==TYPE_MONSTER then
					-- 为本回合标记已记录过“怪兽”种类，该标记在结束阶段复位，确保同一回合内同类卡只计数一次。
					Duel.RegisterFlagEffect(0,49430782,RESET_PHASE+PHASE_END,0,1)
				elseif typ==TYPE_SPELL then
					-- 为本回合标记已记录过“魔法”种类，该标记在结束阶段复位，确保同一回合内同类卡只计数一次。
					Duel.RegisterFlagEffect(0,49430783,RESET_PHASE+PHASE_END,0,1)
				else
					-- 为本回合标记已记录过“陷阱”种类，该标记在结束阶段复位，确保同一回合内同类卡只计数一次。
					Duel.RegisterFlagEffect(0,49430784,RESET_PHASE+PHASE_END,0,1)
				end
			end
		end
		tc=eg:GetNext()
	end
end
-- 在抽卡阶段开始时将真龙卡种类计数器重置为0，使该统计仅适用于本回合。
function c49430782.clearop(e,tp,eg,ep,ev,re,r,rp)
	c49430782.counter=0
end
-- 效果①的发动条件：本回合至少有1种「真龙」卡（怪兽/魔法/陷阱）从场上送去墓地。
function c49430782.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c49430782.counter>0
end
-- 效果①的发动处理：检查当前玩家能否抽对应数量的卡，若可以则向对方显示效果发动提示，并将抽卡数量信息写入连锁操作信息。
function c49430782.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己可以抽取对应数量的卡，若不能抽卡则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,c49430782.counter) end
	-- 向对方玩家提示“已选择发动该效果”，并显示抽卡效果的描述信息。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将本连锁的效果信息设置为“玩家tp抽取counter张卡”，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c49430782.counter)
end
-- 效果①处理时，自己抽取当前计数器数值的卡牌数量。
function c49430782.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前玩家以效果原因抽取counter张卡。
	Duel.Draw(tp,c49430782.counter,REASON_EFFECT)
end
-- 筛选满足条件的卡：必须是「真龙」怪兽，且当前可进行上级召唤（以1只以上怪兽为祭品，并且不占用通常召唤次数）。
function c49430782.sumfilter(c)
	return c:IsSetCard(0xf9) and c:IsSummonable(true,nil,1)
end
-- 效果②发动时确认手牌中存在可以上级召唤的「真龙」怪兽，进行提示并设置连锁信息。
function c49430782.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己手牌中至少存在1张可上级召唤的「真龙」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c49430782.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示已选择发动“上级召唤”效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将本连锁的效果信息设置为“进行1只怪兽的上级召唤”。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②处理时，从手牌选择1只「真龙」怪兽，以解放1只以上怪兽的形式进行表侧上级召唤（不占用通常召唤次数）。
function c49430782.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要上级召唤的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌中选择1张满足条件的「真龙」怪兽作为要上级召唤的卡。
	local g=Duel.SelectMatchingCard(tp,c49430782.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「真龙」怪兽以解放1只以上怪兽的方式进行表侧上级召唤，且不消耗本回合的通常召唤次数。
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- 效果③的发动条件：这张卡从魔法与陷阱区域被送去墓地。
function c49430782.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 效果③发动时，选择场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息。
function c49430782.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 发动时确认场上存在至少1张可作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张魔法·陷阱卡作为效果对象并锁定为目标。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 将本连锁的效果信息设置为“破坏所选择的目标卡”。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③处理时，若对象卡仍与该效果相关，则将其破坏。
function c49430782.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
