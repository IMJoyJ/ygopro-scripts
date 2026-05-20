--飛竜艇－ファンドラ
-- 效果：
-- ①：自己抽卡阶段的抽卡前才能发动。作为这个回合进行通常抽卡的代替，从卡组把1只「空牙团」怪兽加入手卡。
-- ②：自己场上有「空牙团」怪兽5种类以上存在的场合，把场地区域的这张卡送去墓地才能发动。对方场上的卡全部破坏。这个效果的发动后，直到回合结束时对方受到的全部伤害变成0。
function c64400161.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己抽卡阶段的抽卡前才能发动。作为这个回合进行通常抽卡的代替，从卡组把1只「空牙团」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64400161,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c64400161.condition)
	e2:SetTarget(c64400161.target)
	e2:SetOperation(c64400161.operation)
	c:RegisterEffect(e2)
	-- ②：自己场上有「空牙团」怪兽5种类以上存在的场合，把场地区域的这张卡送去墓地才能发动。对方场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64400161,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c64400161.descon)
	e3:SetCost(c64400161.descost)
	e3:SetTarget(c64400161.destg)
	e3:SetOperation(c64400161.desop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c64400161.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己的回合
	return tp==Duel.GetTurnPlayer()
end
-- 过滤卡组中「空牙团」怪兽的条件函数
function c64400161.thfilter(c)
	return c:IsSetCard(0x114) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动目标与合法性检测函数
function c64400161.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定玩家是否能进行通常抽卡，且卡组中是否存在可检索的「空牙团」怪兽
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c64400161.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果①的运行空间与处理函数
function c64400161.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检测玩家是否能进行通常抽卡，若不能则不处理
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使玩家放弃本回合的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	-- 给玩家发送选择加入手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c64400161.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示的「空牙团」卡片的条件函数
function c64400161.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 效果②的发动条件判定函数
function c64400161.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「空牙团」怪兽
	local g=Duel.GetMatchingGroup(c64400161.cfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)>=5
end
-- 效果②的发动代价（Cost）处理函数
function c64400161.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将场地区域的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果②的发动目标与合法性检测函数
function c64400161.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定对方场上是否存在可以破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理信息：破坏对方场上的全部卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的运行空间与处理函数
function c64400161.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏对方场上的全部卡
	Duel.Destroy(g,REASON_EFFECT)
	-- 这个效果的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使对方受到的全部战斗伤害变成0的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使对方受到的全部效果伤害变成0的效果
	Duel.RegisterEffect(e2,tp)
end
