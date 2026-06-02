--朽ちた祭儀要録
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组把1张仪式魔法卡给对方观看，把有那个卡名记述的1只怪兽从卡组加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的仪式怪兽因效果从场上离开的场合，若自己场上没有仪式怪兽以外的表侧表示怪兽存在则能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册“朽坏的祭仪要录”的卡片效果：①魔法卡发动的检索效果，②墓地诱发的回收效果
function s.initial_effect(c)
	-- ①：从手卡·卡组把1张仪式魔法卡给对方观看，把有那个卡名记述的1只怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的仪式怪兽因效果从场上离开的场合，若自己场上没有仪式怪兽以外的表侧表示怪兽存在则能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己手卡·卡组中，未公开的、且卡组中存在记述了该卡名的仪式怪兽的仪式魔法卡
function s.cfilter(c,tp)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL) and not c:IsPublic()
		-- 检查自己卡组中是否存在记载有该仪式魔法卡卡名的仪式怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤条件：卡组中记述了所展示仪式魔法卡卡名的仪式怪兽，且可以加入手卡
function s.thfilter(c,ec)
	-- 过滤条件：卡片文本中记述了对应仪式魔法卡卡名，且是怪兽卡、能加入手卡
	return aux.IsCodeListed(c,ec:GetCode()) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①发动时的效果处理：检查自己手卡·卡组是否存在可展示的仪式魔法卡，并设置将卡组卡片加入手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己手卡·卡组中是否存在可用于展示的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的操作处理：从手卡·卡组让对方确认1张仪式魔法卡，然后将卡组记述了该卡名的一只怪兽加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示：请选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择1张符合条件的仪式魔法卡
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	if cg:GetCount()>0 then
		-- 将选中的仪式魔法卡展示给对方确认
		Duel.ConfirmCards(1-tp,cg)
		-- 给玩家发送提示：请选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只记述了所确认卡片的仪式怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,cg:GetFirst())
		if g:GetCount()>0 then
			-- 将选择的仪式怪兽加入玩家手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的怪兽展示给对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤条件：原本由自己控制的、在怪兽区域表侧表示存在的仪式怪兽，因效果从场上离开
function s.thcfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_RITUAL~=0 and c:IsReason(REASON_EFFECT)
end
-- 效果②的发动条件：自己场上的表侧表示仪式怪兽因效果从场上离开
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
-- 过滤条件：自己场上表侧表示存在的非仪式怪兽
function s.cfilter2(c)
	return c:IsFaceup() and not c:IsType(TYPE_RITUAL)
end
-- 效果②发动时的效果处理：检查这张卡是否能加入手卡，以及自己场上是否没有仪式怪兽以外的表侧表示怪兽，并设置将自身加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 判断自己场上没有仪式怪兽以外的表侧表示怪兽存在
		and not Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：将此卡（墓地中的这张卡）加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的操作处理：若此卡仍存在于墓地且未受王家之谷影响，将此卡加入手卡并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与连锁相关且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手卡的此卡展示给对方确认
		Duel.ConfirmCards(1-tp,c)
	end
end
