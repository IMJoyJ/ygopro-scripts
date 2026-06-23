--三戦の号
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这个回合对方是已把怪兽的效果发动的场合才能发动。从卡组把「三战之号」以外的1张通常魔法·通常陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。对方场上有怪兽存在的场合，也能不盖放加入手卡。
local s,id,o=GetID()
-- 初始化效果，设置卡牌的发动条件、目标和效果处理函数
function s.initial_effect(c)
	-- ①：这个回合对方是已把怪兽的效果发动的场合才能发动。从卡组把「三战之号」以外的1张通常魔法·通常陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。对方场上有怪兽存在的场合，也能不盖放加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 设置一个自定义计数器，用于记录对方在该回合发动的非怪兽效果次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FilterBoolFunction(aux.NOT(Effect.IsActiveType),TYPE_MONSTER))
end
-- 判断对方是否在本回合发动过非怪兽效果
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方在本回合发动过非怪兽效果时条件满足
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0
end
-- 过滤函数，筛选满足条件的通常魔法或通常陷阱卡
function s.filter(c,b1,b2)
	return (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP) and not c:IsCode(id)
		and (b1 and c:IsSSetable() or b2 and c:IsAbleToHand())
end
-- 设置效果的目标，检查是否有满足条件的卡可以发动
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的魔法陷阱区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	local b1=ct>0
	-- 判断对方场上是否存在怪兽
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,b1,b2) end
end
-- 效果处理函数，根据选择决定将卡盖放或加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上是否存在怪兽
	local th=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张满足条件的卡
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,true,th):GetFirst()
	if not tc then return end
	local b1=tc:IsSSetable()
	local b2=th and tc:IsAbleToHand()
	-- 如果可以盖放且选择盖放，则执行盖放操作
	if b1 and (not b2 or Duel.SelectOption(tp,1153,1190)==0) then
		-- 将选中的卡盖放到场上
		Duel.SSet(tp,tc)
		-- 盖放的卡在本回合不能发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	elseif b2 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
