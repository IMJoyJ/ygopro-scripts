--心の架け橋
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「宝玉兽」怪兽召唤。
-- ②：自己主要阶段才能发动。选自己的手卡·场上1张「宝玉兽」卡破坏，从卡组把1张「宝玉」魔法·陷阱卡加入手卡。
-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，以对方场上1张卡为对象才能发动（伤害步骤也能发动）。那张卡和这张卡回到持有者手卡。
local s,id,o=GetID()
-- s.initial_effect函数：为「心之桥梁」注册4个效果，e1为通常魔陷发动的空效果（允许发动），e2为①的额外召唤效果，e3为②的破坏检索效果，e4为③的回手效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「宝玉兽」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"使用「心之桥梁」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 指定EFFECT_EXTRA_SUMMON_COUNT的适用对象为持有「宝玉兽」字段的怪兽，即只有这类怪兽能享受额外召唤次数。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。选自己的手卡·场上1张「宝玉兽」卡破坏，从卡组把1张「宝玉」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，以对方场上1张卡为对象才能发动（伤害步骤也能发动）。那张卡和这张卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_MOVE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- desfilter过滤函数：选择自己手牌中的「宝玉兽」卡，或场上表侧表示的「宝玉兽」卡作为可被破坏的对象。
function s.desfilter(c)
	return c:IsSetCard(0x1034) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
-- thfilter过滤函数：选择卡组中持有「宝玉」字段的魔法·陷阱卡，且能够加入手牌的卡作为检索对象。
function s.thfilter(c)
	return c:IsSetCard(0x34) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- destg的发动合法性检查：确认存在至少1张可破坏的「宝玉兽」卡，且卡组中存在至少1张可加入手牌的「宝玉」魔法·陷阱卡。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手牌或场上是否存在满足条件的1张「宝玉兽」卡（手牌或表侧表示）可供破坏。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		-- 检查卡组中是否存在至少1张满足条件的「宝玉」魔法·陷阱卡可供检索加入手牌。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取所有满足破坏条件的「宝玉兽」卡（手牌+场上表侧），用于后续设置操作信息。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 设置操作信息：本次连锁将破坏1张卡（对象为上述满足条件的卡组），供其他卡牌响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次连锁将从卡组把1张卡加入手牌（对象不确定，预计持有者为tp，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- desop操作处理：先让玩家选择并破坏1张「宝玉兽」卡，若破坏成功，再从卡组选择1张「宝玉」魔法·陷阱卡加入手牌，并让对方确认。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让当前玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己的手牌或场上（表侧）选择1张满足条件的「宝玉兽」卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 若成功选择了卡且该卡被效果破坏成功，则继续执行后续检索处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 弹出选择提示，让当前玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1张满足条件的「宝玉」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入其持有者的手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手牌的卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- cfilter过滤函数：判断移动事件的卡是否为表侧表示、持有「宝玉兽」字段、为我方控制、位于我方魔陷区且不在场地魔法格（序号<5），即是否被放置到魔陷区。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- thcon触发条件：本次移动事件中存在至少1张被放置到我方魔陷区的表侧「宝玉兽」卡。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- thtg发动时点处理：选择对方场上1张能回手牌的卡作为对象，并将「心之桥梁」本身加入对象组，然后设置2张卡返回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	local c=e:GetHandler()
	-- 合法性检查：「心之桥梁」自身能够加入手牌，且对方场上有至少1张可作为对象的卡。
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，让当前玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张能够加入手牌的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g:AddCard(c)
	-- 将「心之桥梁」和选中的对方卡合并为对象组，并设置操作信息：本次连锁将2张卡返回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- thop处理：若「心之桥梁」和对方对象卡仍与效果关联，则将这些卡一起返回各自持有者的手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象（即发动时选择的对方场上那张卡）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将「心之桥梁」和对方场上那张对象卡同时返回持有者手牌。
		Duel.SendtoHand(Group.FromCards(c,tc),nil,REASON_EFFECT)
	end
end
