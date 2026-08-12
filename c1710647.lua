--疫神の依鬼 ヨア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1张「艮神鬼」魔法·陷阱卡在自己场上盖放。
-- ③：对方回合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级上升或下降1星。
local s,id,o=GetID()
-- 注册这张卡的三个效果：①是从手卡特殊召唤的规则手续效果，②是在主要阶段从卡组盖放「艮神鬼」魔法·陷阱卡的起动效果，③是在对方回合取对象改变等级的诱发即时效果
function s.initial_effect(c)
	-- ①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1张「艮神鬼」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：对方回合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级上升或下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"等级变化"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.lvcon)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
-- 特殊召唤代价的过滤函数：选中的卡必须是里侧表示，能作为代价回到手卡或额外卡组，并且该卡离场后自己场上还有可用的主要怪兽区
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 判定该里侧表示卡离开场上后，自己场上是否仍有空余的主要怪兽区可供特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的发动条件：自己场上存在1张满足代价条件的里侧表示卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检索自己场上是否存在至少1张满足条件的里侧表示卡（能回到手卡或额外卡组且离场后有空余怪兽区）
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- 特殊召唤手续的目标选择：从自己场上的里侧表示卡中选择1张作为特殊召唤的代价，并记录下来
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上所有满足代价条件的里侧表示卡组成的卡组
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理：将选中的里侧表示卡给对方观看，然后回到持有者的手卡（或额外卡组）
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选中的里侧表示卡展示给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 以特殊召唤规则的原因将选中的卡送回持有者的手卡（里侧表示的额外卡组怪兽则回到额外卡组）
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 盖放目标的过滤函数：必须是「艮神鬼」系列的魔法·陷阱卡且能够盖放
function s.setfilter(c)
	return c:IsSetCard(0x1e4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动的合法性检查：卡组中是否存在1张可盖放的「艮神鬼」魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的「艮神鬼」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理：让自己从卡组选择1张「艮神鬼」魔法·陷阱卡并在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要盖放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足条件的「艮神鬼」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- ③效果的发动条件：当前是对方的回合
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 等级变化对象的过滤函数：必须是场上表侧表示且等级在1以上的怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- ③效果的目标选择：检查并选择场上1只表侧表示且等级1以上的怪兽作为对象
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 检查场上是否存在至少1只表侧表示且等级1以上的可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择表侧表示的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示且等级1以上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ③效果的处理：若对象怪兽等级为1则只能上升1星，否则让玩家选择上升或下降1星，然后给该怪兽注册等级变化效果
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() then
		local op=0
		if tc:IsLevel(1) then op=1
		-- 让玩家在「等级上升」和「等级下降」两个选项中选择一项
		else op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,3),1},  --"等级上升"
			{true,aux.Stringid(id,4),-1})  --"等级下降"
		end
		-- 那只怪兽的等级上升或下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(op)
		tc:RegisterEffect(e1)
	end
end
