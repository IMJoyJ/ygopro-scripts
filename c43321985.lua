--エンシェント・フェアリー・ライフ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。自己抽1张。场上有「精灵的世界」存在的场合，作为代替从卡组把1只光属性的兽族·植物族·天使族怪兽或者1张「永久圣阳光」加入手卡。
-- ②：自己的「古代妖精龙」以及有那个卡名记述的怪兽可以用表侧守备表示的状态作出攻击（伤害计算把守备力当作攻击力使用）。
local s,id,o=GetID()
-- 初始化效果函数：为古代妖精生命龙注册同调召唤手续、苏生限制、①的抽卡/检索效果（1回合1次，同调召唤成功时发动）和②的守备攻击永续效果。
function s.initial_effect(c)
	-- 将本卡效果文本中记载的卡名「古代妖精龙」（25862681）、「精灵的世界」（5414777）、「永久圣阳光」（28903523）登记到本卡的卡名列表中，以便使用 aux.IsCodeListed 进行“有那个卡名记述”的判定。
	aux.AddCodeList(c,25862681,5414777,28903523)
	-- 为这张卡添加同调召唤手续：1只调整怪兽＋1只以上调整以外的怪兽，即通用同调素材组合。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡同调召唤的场合才能发动。自己抽1张。场上有「精灵的世界」存在的场合，作为代替从卡组把1只光属性的兽族·植物族·天使族怪兽或者1张「永久圣阳光」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己的「古代妖精龙」以及有那个卡名记述的怪兽可以用表侧守备表示的状态作出攻击（伤害计算把守备力当作攻击力使用）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡以同调召唤方式特殊召唤成功时才能发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索的候选卡条件：满足「永久圣阳光」（28903523）或「光属性且兽族·植物族·天使族」之一，并且可以被效果加入手卡的卡。
function s.thfilter(c)
	return (c:IsCode(28903523) or c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST+RACE_FAIRY+RACE_PLANT)) and c:IsAbleToHand()
end
-- 定义①效果的发动目标判定：先检测场上是否存在表侧表示的「精灵的世界」，然后根据有无该卡检查发动是否合法（有则要求卡组存在可检索目标，无则要求玩家可抽卡）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测双方场上是否存在表侧表示且卡号为5414777（「精灵的世界」）的卡。
	local flag=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,5414777)
	-- 效果发动判定（chk==0）：若存在「精灵的世界」，则进一步要求卡组中有符合 s.thfilter 条件的卡，否则这一分支不成立。
	if chk==0 then return flag and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 若不存在「精灵的世界」，则要求玩家可以抽1张卡；两个条件取或，决定①效果能否发动。
		or not flag and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：该效果可能执行抽1张卡（对应后续若无精灵的世界则抽卡的情况），供连锁检测用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的处理：场上没有「精灵的世界」且玩家可抽卡时，抽1张；场上有「精灵的世界」时，从卡组选1张符合条件的卡加入手卡，并展示给对方。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查场上是否存在表侧表示的「精灵的世界」（5414777），以决定走抽卡还是检索分支。
	local flag=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,5414777)
	-- 若场上没有「精灵的世界」且玩家可以抽卡，则进入抽卡分支。
	if not flag and Duel.IsPlayerCanDraw(tp,1) then
		-- 以效果原因让该玩家抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif flag then
		-- 向操作玩家显示“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让操作玩家从自己卡组筛选并选择1张满足 s.thfilter 条件的卡（不取对象，效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选择的卡加入其持有者的手卡（nil 表示加入原持有者的手卡），处理原因为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡片展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义②效果的目标过滤函数：判定我方场上怪兽是否为「古代妖精龙」（25862681）本身，或效果文本中记载了「古代妖精龙」的怪兽。
function s.atktg(e,c)
	-- 判断卡片 c 的卡号是否等于25862681（古代妖精龙），或其效果文本中记载了25862681（古代妖精龙），满足其一即为守备攻击效果的适用对象。
	return c:IsCode(25862681) or aux.IsCodeListed(c,25862681)
end
