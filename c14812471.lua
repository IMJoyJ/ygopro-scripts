--転生炎獣ベイルリンクス
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「转生炎兽的圣域」加入手卡。
-- ②：自己场上的「转生炎兽」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c14812471.initial_effect(c)
	-- 将卡号1295111（转生炎兽的圣域）登记到这张卡的代码列表中，表示此卡卡名中记载了该卡。
	aux.AddCodeList(c,1295111)
	-- 为这张卡设置连接召唤手续：使用1只满足mfilter条件的怪兽作为连接素材，即4星以下的电子界族怪兽1只。
	aux.AddLinkProcedure(c,c14812471.mfilter,1,1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤的场合才能发动。从卡组把1张「转生炎兽的圣域」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14812471,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,14812471)
	e1:SetCondition(c14812471.thcon)
	e1:SetTarget(c14812471.thtg)
	e1:SetOperation(c14812471.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「转生炎兽」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,14812472)
	e2:SetTarget(c14812471.reptg)
	e2:SetValue(c14812471.repval)
	e2:SetOperation(c14812471.repop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：怪兽等级4以下且作为连接素材时种族为电子界。
function c14812471.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- ①效果的发动条件：这张卡以连接召唤的方式特殊召唤成功。
function c14812471.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索目标的过滤条件：卡号为1295111（转生炎兽的圣域）且可以被加入手卡。
function c14812471.thfilter(c)
	return c:IsCode(1295111) and c:IsAbleToHand()
end
-- ①效果发动时进行合法性检查并设置操作信息：卡组存在符合条件的检索目标，且本次操作是将卡组1张卡加入手卡。
function c14812471.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中存在1张符合条件的「转生炎兽的圣域」。
	if chk==0 then return Duel.IsExistingMatchingCard(c14812471.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的处理信息：不取对象地从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时：从卡组选择1张符合条件的「转生炎兽的圣域」加入手牌，并让对手确认。
function c14812471.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter条件的卡（转生炎兽的圣域）作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c14812471.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌，原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代替破坏的判定条件：被破坏的卡是表侧表示、场上、自己控制的「转生炎兽」卡，且破坏原因为战斗或效果，并且不是被代替破坏。
function c14812471.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x119)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②代替破坏效果的发动条件与询问：墓地中的这张卡可除外，且存在将被战斗/效果破坏的自己的「转生炎兽」卡；然后询问玩家是否发动代替破坏。
function c14812471.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c14812471.repfilter,1,nil,tp) end
	-- 让玩家选择是否发动此代替破坏效果（将墓地的这张卡除外代替破坏）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的匹配值：判断被破坏的卡c是否满足repfilter条件，即是否为符合条件的自己场上的「转生炎兽」卡。
function c14812471.repval(e,c)
	return c14812471.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果处理：把墓地中的这张卡表侧表示除外，作为破坏的代替。
function c14812471.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果持有者（这张卡）从墓地除外，以代替被破坏的「转生炎兽」卡。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
