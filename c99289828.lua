--白き森のいいつたえ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有幻想魔族或魔法师族的怪兽存在的场合才能发动。从卡组把1只「白森林」怪兽加入手卡。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册两个效果：①检索「白森林」怪兽；②从墓地盖放自身；两个效果同名卡1回合各能使用1次。
function s.initial_effect(c)
	-- ①：自己场上有幻想魔族或魔法师族的怪兽存在的场合才能发动。从卡组把1只「白森林」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义检索条件：表侧表示且种族为幻想魔族或魔法师族。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
end
-- 效果①的发动条件：自己主要怪兽区存在满足s.cfilter的怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）是否存在至少1只表侧表示且为幻想魔族或魔法师族的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义检索目标过滤：卡组中属于「白森林」系列的怪兽卡且能被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1b1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动时处理：验证卡组中有检索目标，并设置操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认卡组中存在至少1张满足s.thfilter的「白森林」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果包含“将卡组1张卡加入手卡”的检索操作信息，以便其他卡进行响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理时：从卡组选择1张「白森林」怪兽加入手卡，并展示给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.thfilter的「白森林」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：这张卡作为怪兽效果发动的代价被送去墓地，且该效果是已发动且发动源为怪兽。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 效果②的发动时处理：确认这张卡可盖放，并设置操作信息为这张卡将离开墓地盖放到场上。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息：这张卡将离开墓地（盖放到场上），用于配合涉及墓地的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果②处理时：若这张卡仍在墓地且与效果关联，则将其在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果仍关联且可盖放，则将其在自己的魔法与陷阱区域盖放。
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
