--転生炎獣ベイルリンクス
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「转生炎兽的圣域」加入手卡。
-- ②：自己场上的「转生炎兽」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c14812471.initial_effect(c)
	-- 为卡片注册关联卡片「转生炎兽的圣域」的代码，用于后续效果判断
	aux.AddCodeList(c,1295111)
	-- 设置连接召唤手续，需要1个满足条件的连接素材
	aux.AddLinkProcedure(c,c14812471.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「转生炎兽的圣域」加入手卡。
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
-- 连接素材过滤函数，筛选4星以下的电子界族怪兽
function c14812471.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- 效果发动条件判断函数，判断是否为连接召唤
function c14812471.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡牌过滤函数，筛选「转生炎兽的圣域」
function c14812471.thfilter(c)
	return c:IsCode(1295111) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，设置检索目标
function c14812471.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，检查卡组是否存在「转生炎兽的圣域」
	if chk==0 then return Duel.IsExistingMatchingCard(c14812471.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行检索操作
function c14812471.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的「转生炎兽的圣域」
	local g=Duel.SelectMatchingCard(tp,c14812471.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代替破坏的过滤函数，判断是否为我方场上的转生炎兽卡
function c14812471.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x119)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动判断函数，判断是否发动该效果
function c14812471.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c14812471.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的值函数，返回是否满足代替条件
function c14812471.repval(e,c)
	return c14812471.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，执行将卡除外的操作
function c14812471.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
