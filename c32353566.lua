--魔女の聖夜行
local s,id,o=GetID()
-- 定义初始效果函数，用于注册卡片的效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建并注册一个效果，描述为aux.Stringid(id,0)，类别为检索、回手和弃牌，类型为起动效果，作用范围为场地区，限制每回合发动一次，目标选择函数为s.thtg，操作函数为s.thop。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 创建并注册一个效果，类型为场地效果，具有玩家目标属性，代码为id，作用范围为场地区，目标范围为1,0，条件函数为s.effcon。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.effcon)
	c:RegisterEffect(e3)
end
-- 定义过滤函数s.thfilter，用于筛选卡组中符合条件的怪兽卡（种族为魔法师且可加入手牌）。
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义目标选择函数s.thtg，在chk=0时检查是否有满足s.thfilter的卡片存在于卡组中，否则设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足过滤条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示要从卡组回一张牌到手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示要弃一张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 定义效果操作函数s.thop，提示玩家选择加入手牌的卡片，然后执行检索、确认、中断效果、提示玩家选择丢弃的卡片、洗切手牌和送入墓地的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求其选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择一张符合s.thfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 检查是否成功检索到卡片、送入对手手牌以及该卡是否在对手手牌区域。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方玩家确认检索到的卡片。
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果，防止连锁发动。
		Duel.BreakEffect()
		-- 向玩家发送提示信息，要求其选择要丢弃的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家从手牌中选择一张可丢弃的卡片。
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家的手牌。
		Duel.ShuffleHand(tp)
		-- 将选定的卡片送入墓地。
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 定义效果条件函数s.effcon，用于判断当前回合是否为该卡片的控制者回合。
function s.effcon(e)
	-- 返回当前回合的玩家与卡片控制者是否相同。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
