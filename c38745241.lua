--ミニャーマドルチェ・ニャカロン
-- 效果：
-- 包含「魔偶甜点」怪兽的效果怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「魔偶甜点」卡加入手卡。
-- ②：以自己墓地1只怪兽为对象才能发动。从手卡把1只「魔偶甜点」怪兽特殊召唤，作为对象的怪兽回到卡组。这个效果的发动后，直到回合结束时自己不能把「魔偶甜点」怪兽以外的怪兽的效果发动。
local s,id,o=GetID()
-- 为这张卡注册连接召唤手续以及①②两个效果：①在连接召唤成功时检索「魔偶甜点」卡；②以自己墓地1只怪兽为对象，从手牌特殊召唤「魔偶甜点」怪兽并将对象返回卡组，发动后附加不能发动「魔偶甜点」以外怪兽效果的自肃。
function s.initial_effect(c)
	-- 设置这张卡的连接召唤手续：需要2只以上效果怪兽作为连接素材（上限99），并且素材组中至少包含1只「魔偶甜点」怪兽（由s.lcheck判定）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,s.lcheck)
	c:EnableReviveLimit()
	-- 对应①效果：这张卡连接召唤的场合才能发动。从卡组把1张「魔偶甜点」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 对应②效果：以自己墓地1只怪兽为对象才能发动。从手卡把1只「魔偶甜点」怪兽特殊召唤，作为对象的怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接素材检查函数：确认素材组中至少存在1只卡名含有「魔偶甜点」字段（0x71）的怪兽，以满足“包含「魔偶甜点」怪兽”的召唤条件。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x71)
end
-- ①效果的发动条件：这张卡是作为连接召唤成功而特殊召唤时才能发动（即本次特殊召唤的方式为连接召唤）。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的检索过滤器：选择的对象必须具有「魔偶甜点」字段，并且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x71) and c:IsAbleToHand()
end
-- ①效果发动时的目标检查：确认卡组存在至少1张符合条件的「魔偶甜点」卡；照此登记操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：己方卡组中是否存在至少1张「魔偶甜点」字段且能加入手卡的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果将把1张卡从卡组加入手卡（CATEGORY_TOHAND），用于其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：由玩家从卡组选择1张「魔偶甜点」卡加入手卡，并将该卡展示给对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「魔偶甜点」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对手玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的特召过滤器：手牌中的「魔偶甜点」怪兽，并且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的回卡组对象过滤器：自己墓地中的怪兽，并且能够返回卡组。
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果发动时的目标检查：确认自己场上有空余怪兽区、墓地存在可返回卡组的对象、手牌存在可特殊召唤的「魔偶甜点」怪兽，并从墓地选择1只怪兽作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	-- 检查自己场上是否存在可用的怪兽区域（至少1个空格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可以作为对象的怪兽（满足可以返回卡组的条件）。
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查手牌是否存在满足特殊召唤条件的「魔偶甜点」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 显示选择提示，要求玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1只可返回卡组的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本次效果将把对象怪兽返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 登记操作信息：本次效果将从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：从手牌特殊召唤1只「魔偶甜点」怪兽；若特殊召唤成功，则将对象怪兽返回持有者卡组并洗牌。之后给己方附加直到回合结束不能发动「魔偶甜点」以外怪兽效果的自我限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示，要求玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1只满足特殊召唤条件的「魔偶甜点」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 若成功选择了怪兽并特殊召唤成功（返回值为召唤成功数量且不为0），则继续执行后续将对象怪兽返回卡组的处理。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 取得②效果的对象怪兽，即自己墓地中被选择的那只怪兽。
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) then
				-- 将对象怪兽返回其持有者卡组，并触发卡组洗牌。
				Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
	-- 对应②效果的自肃部分：这个效果的发动后，直到回合结束时自己不能把「魔偶甜点」怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果注册到当前操作玩家（tp），使其在本回合结束前受到不能发动「魔偶甜点」以外怪兽效果的制约。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：当即将发动的效果是怪兽效果，且该效果的发动人（handler）不是「魔偶甜点」怪兽时，返回真，从而禁止该效果的发动。
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsSetCard(0x71)
end
