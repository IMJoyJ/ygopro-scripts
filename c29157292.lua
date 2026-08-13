--鋼鉄の幻想師
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放。自己墓地有「金属化·强化反射装甲」存在的场合，再让自己可以抽1张。
-- ②：只要这张卡在怪兽区域存在，这张卡的等级在对方回合内上升4星。
-- ③：宣言1个种族才能发动。这张卡直到对方回合结束时变成宣言的种族。
local s,id,o=GetID()
-- 初始化卡片的全部效果：注册①召唤/特殊召唤时盖放「金属化」陷阱并可能抽卡的效果（e1/e2）、②对方回合等级上升4星的效果（e3）、③宣言种族改变自身种族的效果（e4）。
function s.initial_effect(c)
	-- 将卡号89812483（金属化·强化反射装甲）登记为这张卡记载的卡名，供关联检索/判定使用。
	aux.AddCodeList(c,89812483)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放。自己墓地有「金属化·强化反射装甲」存在的场合，再让自己可以抽1张。（此处e1对应其中“召唤”的触发时点）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放「金属化」陷阱"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡的等级在对方回合内上升4星。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetCondition(s.lvcon)
	e3:SetValue(4)
	c:RegisterEffect(e3)
	-- ③：宣言1个种族才能发动。这张卡直到对方回合结束时变成宣言的种族。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"改变种族"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.racetg)
	e4:SetOperation(s.raceop)
	c:RegisterEffect(e4)
end
-- 定义筛选函数：选择卡组中既是「金属化」字段陷阱卡、又能盖放的卡。
function s.setfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动条件检测：确认自己魔陷区有空位，且卡组中存在符合条件的「金属化」陷阱卡，才可发动。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测自己魔陷区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测卡组中是否存在至少1张满足s.setfilter条件的卡。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理：从卡组选择1张「金属化」陷阱盖放到自己场上；若盖放成功且墓地有「金属化·强化反射装甲」且当前可抽卡，则询问玩家是否追加抽1张。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果自己魔陷区没有空位，则无法盖放，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 给玩家显示选择提示，要求选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中筛选并选择1张符合条件的「金属化」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否满足追加条件：已成功盖放、墓地存在卡号89812483（金属化·强化反射装甲）、且玩家可以抽1张卡。
	if tc and Duel.SSet(tp,tc)~=0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,89812483) and Duel.IsPlayerCanDraw(tp,1)
		-- 让玩家选择是否发动追加抽卡，选择是才继续。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
		-- 使用Duel.BreakEffect中断当前效果处理，使后续抽卡不与盖放同时处理，避免错时点。
		Duel.BreakEffect()
		-- 玩家抽1张卡，抽卡原因记为效果。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②效果的等级上升条件：对方回合（当前回合玩家不是这张卡的控制者）。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不等于卡片控制者，用于判断是否处于对方回合。
	return Duel.GetTurnPlayer()~=e:GetHandler():GetControler()
end
-- ③效果的发动时处理：宣言1个种族，并将宣言的种族存入效果的label。
function s.racetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的种族。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从除当前自身种族以外的全种族中宣言1个种族，作为要变成的种族。
	local race=Duel.AnnounceRace(tp,1,RACE_ALL&~e:GetHandler():GetRace())
	e:SetLabel(race)
end
-- ③效果处理：若卡仍在场上且表侧表示，且当前种族与宣言种族不同，则赋予其改变种族的效果，持续到对方回合结束。
function s.raceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() and bit.band(c:GetRace(),race)==0 then
		-- ③：宣言1个种族才能发动。这张卡直到对方回合结束时变成宣言的种族。（此处对应使种族变化的永续效果部分）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
