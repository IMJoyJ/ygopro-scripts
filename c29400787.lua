--ゴーストリック・パレード
-- 效果：
-- 只要这张卡在场上存在，双方场上的怪兽不能向里侧守备表示怪兽攻击，可以在对方场上的怪兽只有里侧守备表示怪兽的场合直接攻击对方玩家。此外，对方怪兽的直接攻击宣言时，可以从自己卡组把1张名字带有「鬼计」的卡加入手卡。只要这张卡在场上存在，对方玩家受到的全部伤害变成0。
function c29400787.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方场上的怪兽不能向里侧守备表示怪兽攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果值为判断目标怪兽是否为里侧守备表示
	e2:SetValue(aux.TargetBoolFunction(Card.IsFacedown))
	c:RegisterEffect(e2)
	-- 可以在对方场上的怪兽只有里侧守备表示怪兽的场合直接攻击对方玩家
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c29400787.dirtg)
	c:RegisterEffect(e3)
	-- 对方怪兽的直接攻击宣言时，可以从自己卡组把1张名字带有「鬼计」的卡加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29400787,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c29400787.thcon)
	e4:SetTarget(c29400787.thtg)
	e4:SetOperation(c29400787.thop)
	c:RegisterEffect(e4)
	-- 只要这张卡在场上存在，对方玩家受到的全部伤害变成0
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(0)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e6)
end
-- 判断是否己方场上没有表侧表示怪兽
function c29400787.dirtg(e,c)
	-- 若己方场上没有表侧表示怪兽则返回true
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 判断攻击方是否为对方且攻击目标为空
function c29400787.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若攻击方为对方且攻击目标为空则返回true
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤函数：检索名字带有「鬼计」且可以加入手牌的卡
function c29400787.filter(c)
	return c:IsSetCard(0x8d) and c:IsAbleToHand()
end
-- 设置连锁操作信息：检索满足条件的卡并准备加入手牌
function c29400787.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否己方卡组存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29400787.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果：选择并加入手牌，确认对方看到加入手牌的卡
function c29400787.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c29400787.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方能看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
