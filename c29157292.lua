--鋼鉄の幻想師
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放。自己墓地有「金属化·强化反射装甲」存在的场合，再让自己可以抽1张。
-- ②：只要这张卡在怪兽区域存在，这张卡的等级在对方回合内上升4星。
-- ③：宣言1个种族才能发动。这张卡直到对方回合结束时变成宣言的种族。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 记录该卡拥有「金属化·强化反射装甲」的卡名
	aux.AddCodeList(c,89812483)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放。
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
-- 检索满足条件的「金属化」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 设置盖放陷阱卡的处理条件
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的魔陷区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断卡组中是否存在满足条件的陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行盖放陷阱卡和抽卡的效果处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有足够的魔陷区空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否满足抽卡条件
	if tc and Duel.SSet(tp,tc)~=0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,89812483) and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 执行抽卡效果
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断等级上升效果是否触发
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡控制者
	return Duel.GetTurnPlayer()~=e:GetHandler():GetControler()
end
-- 设置宣言种族效果的处理条件
function s.racetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家宣言一个种族
	local race=Duel.AnnounceRace(tp,1,RACE_ALL&~e:GetHandler():GetRace())
	e:SetLabel(race)
end
-- 执行种族变更效果
function s.raceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() and bit.band(c:GetRace(),race)==0 then
		-- 变更该卡的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
