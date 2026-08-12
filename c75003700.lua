--星辰槍手ルキアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「星辰枪手 巨蟹魔」以外的1只「星辰」怪兽加入手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册该卡效果：①召唤·特殊召唤成功的场合，从卡组把「星辰枪手 巨蟹魔」以外的1只「星辰」怪兽加入手卡；②这张卡作为融合素材送墓的场合，从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「星辰枪手 巨蟹魔」以外的1只「星辰」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放魔陷"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 检索怪兽的过滤条件（不能是同名卡、属于「星辰」的怪兽卡，且可以加入手卡）
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c9) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①号检索效果的发动准备（判定卡组是否有符合条件的怪兽，并设定操作信息）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在符合检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索并加入手卡的操作信息（从卡组中选择1张卡）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号检索效果的效果处理（从卡组中检索符合条件的怪兽加入手卡，并展示给对方确认）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②号盖放效果的发动条件判定（作为融合素材被送去墓地且不为回到墓地的场合）
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤卡组中的「星辰」魔法·陷阱卡（必须满足可在场上盖放的条件）
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②号盖放效果的发动准备（判定卡组中是否有符合盖放条件的卡）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在符合盖放条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②号盖放效果的效果处理（检查场上是否有空格后，从卡组中选择符合条件的魔法·陷阱卡在场上盖放）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上的魔法·陷阱区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择符合条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 在自己场上盖放选择的卡片
		Duel.SSet(tp,tc)
	end
end
