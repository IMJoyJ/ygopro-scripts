--巳剣之磐境
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把自己场上的「巳剑」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
-- ②：以「巳剑之磐境」以外的自己墓地4张「巳剑」卡为对象才能发动。那些卡回到卡组。对方场上有怪兽存在的场合，再让对方必须把自身场上1只怪兽解放。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- ①：对方不能把自己场上的「巳剑」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
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
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 过滤目标怪兽是否为仪式怪兽且为巳剑卡组
function s.tfilter(e,c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x1c3)
end
-- 判断效果是否适用于对方从额外卡组特殊召唤的怪兽
function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and rp==1-e:GetHandlerPlayer()
end
-- 过滤墓地中的巳剑卡牌
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToDeck()
end
-- 设置效果的发动条件和目标选择函数
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查是否满足发动条件：墓地存在4张巳剑卡，且对方场上存在怪兽或对方可以解放怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,4,nil)
		-- 检查是否满足发动条件：墓地存在4张巳剑卡，且对方场上存在怪兽或对方可以解放怪兽
		and (Duel.GetFieldGroup(tp,0,LOCATION_MZONE)==0 or Duel.IsPlayerCanRelease(1-tp)) end
	-- 提示玩家选择要送回卡组的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择4张满足条件的墓地卡牌作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	-- 设置效果处理时的操作信息，指定将卡牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 设置效果的处理函数
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组，并过滤掉受王家长眠之谷影响的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	-- 将符合条件的卡牌送回卡组并洗牌
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) then
		-- 获取实际被操作的卡牌组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 检查对方是否可以解放1只怪兽
			and Duel.CheckReleaseGroupEx(1-tp,nil,1,REASON_RULE,false,nil) then
			-- 选择对方场上1只怪兽进行解放
			local sg=Duel.SelectReleaseGroupEx(1-tp,nil,1,1,REASON_RULE,false,nil)
			if sg:GetCount()>0 then
				-- 中断当前效果处理，使后续处理错开时点
				Duel.BreakEffect()
				-- 显示所选怪兽被解放的动画效果
				Duel.HintSelection(sg)
				-- 对选中的怪兽进行解放操作
				Duel.Release(sg,REASON_RULE,1-tp)
			end
		end
	end
end
