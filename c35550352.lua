--Start for VS！
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己场上1只「征服斗魂」怪兽为对象才能发动。和那只怪兽属性不同的1只「征服斗魂」怪兽从卡组加入手卡。
-- ②：自己场上的「征服斗魂」怪兽被战斗·效果破坏的场合，可以作为代替把手卡1只「征服斗魂」怪兽给人观看。
-- ③：自己结束阶段，自己场上有「征服斗魂」怪兽2只以上存在的场合才能发动。从卡组把1张「征服斗魂」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动和三个效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只「征服斗魂」怪兽为对象才能发动。和那只怪兽属性不同的1只「征服斗魂」怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己场上的「征服斗魂」怪兽被战斗·效果破坏的场合，可以作为代替把手卡1只「征服斗魂」怪兽给人观看。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段，自己场上有「征服斗魂」怪兽2只以上存在的场合才能发动。从卡组把1张「征服斗魂」陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 筛选场上满足条件的「征服斗魂」怪兽，用于效果①的对象选择
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x195)
		-- 检查卡组中是否存在与目标怪兽属性不同的「征服斗魂」怪兽
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 筛选卡组中满足条件的「征服斗魂」怪兽（属性不同、可加入手牌、为怪兽）
function s.sfilter(c,attr)
	return not c:IsAttribute(attr) and c:IsSetCard(0x195)
		and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 效果①的目标选择函数，选择场上满足条件的怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 判断效果①是否可以发动，检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果①的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上满足条件的怪兽作为效果①的对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果①的处理信息，表示将从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，执行将目标怪兽属性不同的怪兽加入手牌的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local attr=tc:GetAttribute()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择一张属性与目标怪兽不同的「征服斗魂」怪兽
		local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,attr)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 筛选场上被破坏的「征服斗魂」怪兽，用于效果②的代替破坏判断
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x195) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 筛选手牌中满足条件的「征服斗魂」怪兽，用于效果②的代替破坏消耗
function s.spcostfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果②的目标判断函数，检查是否有满足条件的怪兽被破坏且手牌中有可消耗的怪兽
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		-- 检查手牌中是否存在满足条件的「征服斗魂」怪兽
		and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 询问玩家是否发动效果②
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 效果②的代替破坏值函数，返回是否满足代替破坏条件
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 效果②的处理函数，执行将手牌中的怪兽给对方确认并洗切手牌的操作
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择一张满足条件的「征服斗魂」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 向对方确认选择的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手牌洗切
	Duel.ShuffleHand(tp)
end
-- 筛选场上满足条件的「征服斗魂」怪兽，用于效果③的发动条件
function s.onfilter(c)
	return c:IsSetCard(0x195) and c:IsFaceup()
end
-- 效果③的发动条件函数，检查当前回合玩家场上的「征服斗魂」怪兽数量是否大于等于2
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计当前回合玩家场上的「征服斗魂」怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.onfilter,tp,LOCATION_MZONE,0,nil)
	-- 判断当前回合玩家是否满足发动效果③的条件
	return Duel.GetTurnPlayer()==tp and ct>=2
end
-- 筛选卡组中满足条件的「征服斗魂」陷阱卡，用于效果③的盖放
function s.setfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果③的目标选择函数，检查卡组中是否存在满足条件的陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断效果③是否可以发动，检查卡组中是否存在满足条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果③的处理函数，执行从卡组选择陷阱卡并盖放的操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张满足条件的「征服斗魂」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡盖放在场上
		Duel.SSet(tp,g)
	end
end
