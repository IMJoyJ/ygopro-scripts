--粛声なる結界
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有「肃声的祈祷者 理」以及光属性仪式怪兽存在，对方怪兽只能选择仪式怪兽作为攻击对象，对方不能把自己场上的光属性怪兽作为效果的对象。
-- ②：自己主要阶段才能发动。除「肃声之结界」外的1张「肃声」卡或1只「法理守护者」仪式怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：e0为魔陷发动效果，e1为对方不能直接攻击，e2为对方只能选择仪式怪兽作为攻击对象，e3为对方不能选择己方光属性怪兽作为效果对象，e4为主要阶段检索「肃声」卡或「法理守护者」仪式怪兽
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有「肃声的祈祷者 理」以及光属性仪式怪兽存在，对方怪兽只能选择仪式怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(s.alimit)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果e3的影响对象为己方场上的光属性怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	-- 设置效果e3的价值函数，使目标怪兽不会成为对方卡片效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：自己主要阶段才能发动。除「肃声之结界」外的1张「肃声」卡或1只「法理守护者」仪式怪兽从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"检索"
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的「肃声的祈祷者 理」，且场上存在另一只光属性仪式怪兽
function s.cfilter1(c,tp)
	return c:IsFaceup() and c:IsCode(25801745)
		-- 检查自己场上是否存在除当前卡以外的、满足过滤条件s.cfilter2（光属性仪式怪兽）的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤条件：表侧表示的光属性仪式怪兽
function s.cfilter2(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_RITUAL)
end
-- 永续效果的适用条件：自己场上同时存在「肃声的祈祷者 理」和光属性仪式怪兽
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在满足过滤条件s.cfilter1的卡（即「肃声的祈祷者 理」且场上还有光属性仪式怪兽）
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- 攻击目标限制：不能选择里侧表示怪兽或非仪式怪兽作为攻击对象
function s.alimit(e,c)
	return c:IsFacedown() or not c:IsType(TYPE_RITUAL)
end
-- 过滤条件：卡组中除「肃声之结界」以外的「肃声」卡片，或者「法理守护者」仪式怪兽，且该卡能加入手卡
function s.filter(c)
	return (c:IsSetCard(0x1a6) or c:IsSetCard(0x2052) and c:GetType()&0x81==0x81) and c:IsAbleToHand()
		and not c:IsCode(id)
end
-- 检索效果的发动准备：检查卡组中是否存在可检索的卡，并设置将卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件s.filter的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：让玩家从卡组选择1张满足条件的卡加入手卡，并向对方展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件s.filter的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片通过效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
