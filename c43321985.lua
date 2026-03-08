--エンシェント・フェアリー・ライフ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。自己抽1张。场上有「精灵的世界」存在的场合，作为代替从卡组把1只光属性的兽族·植物族·天使族怪兽或者1张「永久圣阳光」加入手卡。
-- ②：自己的「古代妖精龙」以及有那个卡名记述的怪兽可以用表侧守备表示的状态作出攻击（伤害计算把守备力当作攻击力使用）。
local s,id,o=GetID()
-- 初始化效果函数，注册同调召唤手续、设置效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着25862681、5414777、28903523这三张卡的卡号
	aux.AddCodeList(c,25862681,5414777,28903523)
	-- 设置该卡的同调召唤手续为：1只调整+1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。自己抽1张。场上有「精灵的世界」存在的场合，作为代替从卡组把1只光属性的兽族·植物族·天使族怪兽或者1张「永久圣阳光」加入手卡。
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
-- 判断是否为同调召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索满足条件的卡（为「永久圣阳光」或为光属性的兽族·植物族·天使族怪兽）
function s.thfilter(c)
	return (c:IsCode(28903523) or c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST+RACE_FAIRY+RACE_PLANT)) and c:IsAbleToHand()
end
-- 设置效果的发动条件和目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在「精灵的世界」
	local flag=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,5414777)
	-- 若场上存在「精灵的世界」且卡组中有满足条件的卡，则可以发动效果
	if chk==0 then return flag and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 若场上不存在「精灵的世界」且玩家可以抽卡，则可以发动效果
		or not flag and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理时的抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果的发动和执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「精灵的世界」
	local flag=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,5414777)
	-- 若场上不存在「精灵的世界」且玩家可以抽卡，则执行抽卡操作
	if not flag and Duel.IsPlayerCanDraw(tp,1) then
		-- 执行抽卡操作
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif flag then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看送入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 设置攻击时的判定条件
function s.atktg(e,c)
	-- 判断目标怪兽是否为「古代妖精龙」或其效果文本上记载着该卡名
	return c:IsCode(25862681) or aux.IsCodeListed(c,25862681)
end
