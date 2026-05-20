--霊神の聖殿
-- 效果：
-- ①：自己场上的怪兽的攻击力·守备力上升自己墓地的怪兽的属性种类×200。
-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「元素灵剑士」怪兽加入手卡。那之后，下次的自己回合的战斗阶段跳过。
-- ③：1回合1次，自己的手卡·场上的「元素灵剑士」怪兽为让效果发动而把手卡送去墓地的场合，可以作为代替把卡组的「元素灵剑士」怪兽送去墓地。
function c61557074.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽的攻击力上升自己墓地的怪兽的属性种类×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c61557074.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「元素灵剑士」怪兽加入手卡。那之后，下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61557074,0))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c61557074.thtg)
	e4:SetOperation(c61557074.thop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己的手卡·场上的「元素灵剑士」怪兽为让效果发动而把手卡送去墓地的场合，可以作为代替把卡组的「元素灵剑士」怪兽送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(61557074,1))
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(61557074)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCountLimit(1)
	e5:SetTargetRange(1,0)
	c:RegisterEffect(e5)
end
-- 计算攻击力上升值的辅助函数
function c61557074.atkval(e,c)
	-- 获取自己墓地怪兽的属性种类数量并乘以200
	return Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER):GetClassCount(Card.GetAttribute)*200
end
-- 过滤卡组中可加入手牌的「元素灵剑士」怪兽
function c61557074.thfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测
function c61557074.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可加入手牌的「元素灵剑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61557074.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行，将怪兽加入手牌并注册跳过下次战斗阶段的效果
function c61557074.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「元素灵剑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c61557074.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选择卡片且成功将其加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 那之后，下次的自己回合的战斗阶段跳过。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		-- 判断当前回合是否为自己的回合
		if Duel.GetTurnPlayer()==tp then
			-- 将当前回合数记录在效果的Label中，用于后续判断是否为“下次”回合
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c61557074.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 注册跳过战斗阶段的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否跳过战斗阶段的条件函数
function c61557074.skipcon(e)
	-- 确保跳过战斗阶段的效果在当前回合不生效（即在下一次自己的回合生效）
	return Duel.GetTurnCount()~=e:GetLabel()
end
