--ゴーティスの大蛇アリオンポス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把1只6星以下的鱼族怪兽除外。
-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽除外。那之后，可以把持有那只怪兽的等级以下的等级的1只鱼族怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、①效果（同调召唤成功时从卡组除外鱼族怪兽）和②效果（作为同调素材送去墓地时除外墓地鱼族并检索鱼族怪兽）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡同调召唤的场合才能发动。从卡组把1只6星以下的鱼族怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽除外。那之后，可以把持有那只怪兽的等级以下的等级的1只鱼族怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon2)
	e2:SetTarget(s.rmtg2)
	e2:SetOperation(s.rmop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡是通过同调召唤特殊召唤的。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中等级6以下且可以除外的鱼族怪兽。
function s.rmfilter(c)
	return c:IsRace(RACE_FISH) and c:IsLevelBelow(6) and c:IsAbleToRemove()
end
-- 效果①的发动准备与合法性检测（检查卡组中是否存在符合条件的卡，并设置除外操作信息）。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1只等级6以下的鱼族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息，表示此效果会从卡组除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的实际处理：从卡组选择1只等级6以下的鱼族怪兽除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从卡组中选择1只符合过滤条件的鱼族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡在墓地，且是因为作为同调素材而被送去墓地。
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤自己墓地中可以除外的鱼族怪兽。
function s.rmfilter2(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemove()
end
-- 效果②的发动准备与对象选择（选择自己墓地1只鱼族怪兽为对象，并设置除外操作信息）。
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter2(chkc) end
	-- 检查自己墓地中是否存在至少1只可以除外的鱼族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片（作为效果对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中的1只鱼族怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.rmfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理中的操作信息，表示此效果会除外指定的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 过滤卡组中等级在指定数值以下、可以加入手牌的鱼族怪兽。
function s.thfilter(c,lv)
	return c:IsRace(RACE_FISH) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end
-- 效果②的实际处理：除外作为对象的墓地怪兽，之后可以从卡组把持有该怪兽等级以下的1只鱼族怪兽加入手牌。
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的唯一对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FISH)
		-- 成功将对象怪兽表侧表示除外，且该卡确实移动到了除外区。
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED)
		-- 检查被除外怪兽的等级是否大于0，且卡组中是否存在等级在其以下并可加入手牌的鱼族怪兽。
		and tc:GetLevel()>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tc:GetLevel())
		-- 询问玩家是否选择执行后续的“从卡组把鱼族怪兽加入手卡”效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组把鱼族怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择1只等级在被除外怪兽等级以下的鱼族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
		-- 中断当前效果处理，使后续的加入手牌处理与除外处理不视为同时进行（防止错时点）。
		Duel.BreakEffect()
		-- 将选中的鱼族怪兽加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
