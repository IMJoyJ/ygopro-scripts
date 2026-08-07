--死相の冥鑑ヒュブロ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。除「死相之冥鉴 许布洛」外的1只6星以上的不死族怪兽从卡组送去墓地。那之后，可以从自己墓地把1只6星以上的不死族怪兽加入手卡。
-- ③：这张卡在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合才能发动。进行1只不死族超量怪兽的超量召唤。
local s,id,o=GetID()
-- 注册卡片初始化效果：不用解放作召唤的召唤手续效果、召唤·特殊召唤时从卡组堆墓并可选回收墓地不死族怪兽的效果，以及从墓地特召怪兽时诱发进行不死族超量召唤的效果。
function s.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。除「死相之冥鉴 许布洛」外的1只6星以上的不死族怪兽从卡组送去墓地。那之后，可以从自己墓地把1只6星以上的不死族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_GRAVE_ACTION+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合才能发动。进行1只不死族超量怪兽的超量召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"超量召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 不用解放作召唤的条件检查函数：检查所需解放数量为0、等级为5星以上且控制者场上有怪兽区域空位。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤所需解放数是否为0、怪兽等级是否在5星以上且场上有可用怪兽格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 卡组送去墓地怪兽过滤函数：检查卡片是否非同名卡、等级6星以上、不死族且能送去墓地。
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- 召唤·特召时堆墓效果的目标检查函数：检查卡组是否存在满足送墓条件的不死族怪兽，并设置操作信息与提示。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张除「死相之冥鉴 许布洛」外的6星以上不死族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家提示发动了此效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 回收手牌怪兽过滤函数：检查卡片是否为6星以上不死族怪兽且能加入手牌。
function s.thfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
-- 召唤·特召时堆墓及回收手牌的处理函数：从卡组把1只6星以上不死族怪兽送去墓地，之后可以从自己墓地把1只6星以上不死族怪兽加入手卡。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张除「死相之冥鉴 许布洛」外的6星以上不死族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断所选卡片成功通过效果送去墓地且到达墓地。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取自己墓地中满足条件且不受王家长眠之谷影响的可回收怪兽组。
		local gg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在满足条件的怪兽，询问玩家是否将其加入手卡。
		if gg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否加入手卡？"
			-- 中断效果处理，使后续加入手卡处理与送去墓地不同时处理。
			Duel.BreakEffect()
			-- 弹出提示要求玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=gg:Select(tp,1,1,nil)
			-- 高亮显示在墓地中被选为目标的卡片。
			Duel.HintSelection(sg)
			-- 将选中的怪兽从墓地加入手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
-- 特殊召唤怪兽过滤函数：检查怪兽是否从墓地特殊召唤且原本类型为怪兽。
function s.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 墓地有怪兽特召时效果的条件检查函数：检查是否有怪兽从墓地特殊召唤且不包含自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 超量召唤怪兽过滤函数：检查卡片是否为不死族且当前能进行超量召唤。
function s.xyzfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsXyzSummonable(nil)
end
-- 墓地特召时诱发超量召唤效果的目标检查函数：检查额外卡组是否存在可超量召唤的不死族超量怪兽，并设置操作信息与提示。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1张可以超量召唤的不死族超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置当前连锁的操作信息为从额外卡组进行1次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示发动了此效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 进行不死族超量召唤的处理函数：从额外卡组选择1只可超量召唤的不死族超量怪兽进行超量召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组中所有可超量召唤的不死族超量怪兽。
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 弹出提示要求玩家选择要特殊召唤的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 对选中的怪兽进行超量召唤。
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
