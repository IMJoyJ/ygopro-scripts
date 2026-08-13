--ゴーストリック・パレード
-- 效果：
-- 只要这张卡在场上存在，双方场上的怪兽不能向里侧守备表示怪兽攻击，可以在对方场上的怪兽只有里侧守备表示怪兽的场合直接攻击对方玩家。此外，对方怪兽的直接攻击宣言时，可以从自己卡组把1张名字带有「鬼计」的卡加入手卡。只要这张卡在场上存在，对方玩家受到的全部伤害变成0。
function c29400787.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方场上的怪兽不能向里侧守备表示怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置该值后，本效果将禁止选择里侧守备表示怪兽作为攻击对象（即双方场上的怪兽不能向里侧守备表示怪兽攻击）。
	e2:SetValue(aux.TargetBoolFunction(Card.IsFacedown))
	c:RegisterEffect(e2)
	-- 可以在对方场上的怪兽只有里侧守备表示怪兽的场合直接攻击对方玩家。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c29400787.dirtg)
	c:RegisterEffect(e3)
	-- 此外，对方怪兽的直接攻击宣言时，可以从自己卡组把1张名字带有「鬼计」的卡加入手卡。
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
	-- 只要这张卡在场上存在，对方玩家受到的全部伤害变成0。
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
-- 这是“可以直接攻击”效果的判定函数：若攻击怪兽的控制者（c:GetControler()）的对方场上不存在表侧表示怪兽，则允许该怪兽直接攻击对方玩家。
function c29400787.dirtg(e,c)
	-- 检查攻击怪兽控制者的对方场上不存在表侧表示怪兽（即对方场上只有里侧守备表示怪兽或没有怪兽），从而允许其直接攻击。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 该函数是“加入手卡”诱发效果的发动条件：仅在对方怪兽进行直接攻击宣言时满足。
function c29400787.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 本次攻击宣言的攻击怪兽为对方怪兽，且其攻击目标为nil（即直接攻击），从而判断为对方怪兽的直接攻击宣言。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 检索过滤函数：所选卡片必须是名字带有「鬼计」（字段0x8d）的卡，且该卡能够加入手卡。
function c29400787.filter(c)
	return c:IsSetCard(0x8d) and c:IsAbleToHand()
end
-- 该函数是效果的发动条件和处理前登记：在发动时先确认卡组中是否存在1张可检索的鬼计卡，若存在则允许发动，并登记本次操作会把1张卡从卡组加入手卡。
function c29400787.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，检查卡组中是否存在至少1张满足鬼计字段且可加入手卡的卡，决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29400787.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本次操作信息：效果处理时会将1张卡从卡组加入手卡（CATEGORY_TOHAND），数量为1，目标位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 该函数是效果处理时的操作：先给出选择提示，再从卡组选择1张符合条件的鬼计卡加入手卡，若成功加入则向对方玩家展示该卡。
function c29400787.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示消息，提示语为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组中筛选并选择1张满足filter条件（鬼计字段且能加入手卡）的卡。
	local g=Duel.SelectMatchingCard(tp,c29400787.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡片以效果原因加入其持有者的手卡（player为nil，因此回到原持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
