--伝説の剣闘士 カオス・ソルジャー
-- 效果：
-- 「混沌形态」「超战士的仪式」降临
-- 这张卡不用仪式召唤不能特殊召唤。
-- ①：自己抽卡阶段的抽卡前，把手卡的这张卡给对方观看才能发动。作为这个回合进行通常抽卡的代替，从卡组把1张仪式魔法卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己战斗阶段中对方不能把效果发动。
-- ③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 记录这张卡记有「混沌形态」和「超战士的仪式」的卡名
	aux.AddCodeList(c,21082832,14094090)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置仪式召唤以外不能特殊召唤的苏生限制
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：自己抽卡阶段的抽卡前，把手卡的这张卡给对方观看才能发动。作为这个回合进行通常抽卡的代替，从卡组把1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己战斗阶段中对方不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(s.rhcon)
	e4:SetTarget(s.rhtg)
	e4:SetOperation(s.rhop)
	c:RegisterEffect(e4)
	-- ③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.matcon)
	e5:SetOperation(s.matop)
	c:RegisterEffect(e5)
	-- ③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(s.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
-- 判断当前是否为自己的回合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 发动代价：将手牌的这张卡给对方观看
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤可以从卡组检索的仪式魔法卡
function s.thfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- 效果①的发动检测与效果目标声明
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否可以进行通常抽卡，且卡组中存在可检索的仪式魔法卡
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将卡组的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：代替通常抽卡，从卡组将1张仪式魔法卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己不能进行通常抽卡则不能处理效果
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使玩家放弃本回合抽卡阶段的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	-- ①：自己抽卡阶段的抽卡前，把手卡的这张卡给对方观看才能发动。作为这个回合进行通常抽卡的代替，从卡组把1张仪式魔法卡加入手卡。/②：只要这张卡在怪兽区域存在，自己战斗阶段中对方不能把效果发动。/③：使用通常怪兽作仪式召唤的这张卡的攻击破坏对方怪兽时才能发动。对方场上的卡全部回到卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	e1:SetValue(0)
	-- 注册将通常抽卡抽卡数变为0的效果
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张符合检索条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的仪式魔法卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检测自己是否处于战斗阶段中
function s.actcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 返回当前是否为自己的战斗阶段
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 判断是否使用通常怪兽作仪式召唤成功
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 为这张卡注册使用通常怪兽仪式召唤成功的标记
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 检查仪式召唤使用的素材中是否存在通常怪兽，并设置相应的标签值
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为仪式召唤时使用了通常怪兽的这张卡攻击破坏了对方怪兽
function s.rhcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回是否为仪式召唤时使用了通常怪兽的这张卡攻击破坏了对方怪兽
	return c:GetFlagEffect(id)>0 and Duel.GetAttacker()==c
end
-- 效果③的发动检测与效果目标声明
function s.rhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以回到卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理时将对方场上所有卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果③的效果处理：使对方场上的卡全部回到卡组
function s.rhop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以回到卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将这些卡因效果送回卡组并洗卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
