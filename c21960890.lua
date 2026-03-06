--大屍教
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡·卡组把1只恶魔族·不死族的仪式怪兽送去墓地。那之后，可以从卡组把1张仪式魔法卡加入手卡。
-- ②：这张卡被除外的场合，以自己的除外状态的1只4星以下的恶魔族·不死族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册大尸教的两个效果，分别对应①②效果，①效果在通常召唤或特殊召唤成功时发动，②效果在被除外时发动
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡·卡组把1只恶魔族·不死族的仪式怪兽送去墓地。那之后，可以从卡组把1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合，以自己的除外状态的1只4星以下的恶魔族·不死族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于筛选满足条件的恶魔族·不死族仪式怪兽（可送去墓地）
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE+RACE_FIEND) and c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果处理的初始化函数，检查是否存在满足条件的怪兽（用于发动条件判断）
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的恶魔族·不死族仪式怪兽（用于发动条件判断）
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡的类型为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义过滤函数，用于筛选满足条件的仪式魔法卡（可加入手牌）
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果处理函数，执行将仪式怪兽送去墓地并检索仪式魔法卡的操作
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只恶魔族·不死族仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地，并确认是否成功送入墓地
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 获取卡组中所有满足条件的仪式魔法卡
			local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			-- 判断是否有满足条件的仪式魔法卡，并询问玩家是否加入手牌
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
				-- 中断当前效果处理，使后续操作视为不同时处理
				Duel.BreakEffect()
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将选中的仪式魔法卡加入手牌
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 向对方确认加入手牌的卡
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end
-- 定义过滤函数，用于筛选满足条件的除外状态的恶魔族·不死族4星以下怪兽（可特殊召唤）
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_FIEND+RACE_ZOMBIE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的初始化函数，检查是否存在满足条件的除外怪兽（用于发动条件判断）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的除外怪兽（用于发动条件判断）
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只除外状态的恶魔族·不死族4星以下怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，指定将要处理的卡的类型为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行将选中的除外怪兽特殊召唤的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
