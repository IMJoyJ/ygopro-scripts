--巳剣之磐境
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把自己场上的「巳剑」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
-- ②：以「巳剑之磐境」以外的自己墓地4张「巳剑」卡为对象才能发动。那些卡回到卡组。对方场上有怪兽存在的场合，再让对方必须把自身场上1只怪兽解放。
local s,id,o=GetID()
-- 定义卡片效果初始化函数，用于注册各种效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方不能把自己场上的「巳剑」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tfilter)
	e2:SetValue(s.evalue)
	c:RegisterEffect(e2)
	-- ②：以「巳剑之磐境」以外的自己墓地4张「巳剑」卡为对象才能发动。那些卡回到卡组。对方场上有怪兽存在的场合，再让对方必须把自身场上1只怪兽解放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 定义一个过滤函数，用于判断卡片是否是仪式怪兽且属于“巳剑”系列。
function s.tfilter(e,c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x1c3)
end
-- 定义一个值计算函数，用于判断效果的目标是否为从额外卡组特殊召唤的怪兽，并且玩家是否不同。
function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and rp==1-e:GetHandlerPlayer()
end
-- 定义一个过滤函数，用于选择墓地的“巳剑”卡片（排除“巳剑之磐境”本身）。
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToDeck()
end
-- 定义目标选择函数，用于选择要送回卡组的“巳剑”卡片，并检查对方场上是否存在怪兽。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 如果正在确认选择，则返回满足过滤条件的卡片是否位于墓地且为玩家控制。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,4,nil)
		-- 如果尚未进行选择，则检查是否有4张或更多符合条件的卡片存在于墓地中，以及对方场上是否存在怪兽或者对方是否可以解放怪兽。
		and (Duel.GetFieldGroup(tp,0,LOCATION_MZONE)==0 or Duel.IsPlayerCanRelease(1-tp)) end
	-- 向玩家提示需要选择要送回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从墓地中选择最多4张满足过滤条件的“巳剑”卡片。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	-- 设置操作信息，表明当前连锁处理的是将选定的卡片送回卡组的效果。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 定义效果执行函数，用于将选定的卡片送回卡组，并根据对方场上是否存在怪兽来决定是否强制解放对方的怪兽。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的目标卡片组。
	local g=Duel.GetTargetsRelateToChain()
	-- 如果存在目标卡片且成功将其送回卡组，则继续执行后续操作。
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 获取被本次效果操作过的卡片组。
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 检查对方场上是否存在怪兽，并且玩家是否可以解放怪兽。
			and Duel.CheckReleaseGroupEx(1-tp,nil,1,REASON_RULE,false,nil) then
			-- 让对方选择一张怪兽进行解放。
			local sg=Duel.SelectReleaseGroupEx(1-tp,nil,1,1,REASON_RULE,false,nil)
			if sg:GetCount()>0 then
				-- 中断当前效果，防止连锁处理的冲突。
				Duel.BreakEffect()
				-- 手动显示被选为对象的动画效果。
				Duel.HintSelection(sg)
				-- 解放选定的怪兽。
				Duel.Release(sg,REASON_RULE,1-tp)
			end
		end
	end
end
