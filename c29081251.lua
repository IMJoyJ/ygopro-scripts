--死相の冥鑑ヒュブロ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。除「死相之冥鉴 许布洛」外的1只6星以上的不死族怪兽从卡组送去墓地。那之后，可以从自己墓地把1只6星以上的不死族怪兽加入手卡。
-- ③：这张卡在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合才能发动。进行1只不死族超量怪兽的超量召唤。
local s,id,o=GetID()
-- 初始化卡片效果（通召免解放手续、召唤·特招时从卡组把6星以上不死族送墓并可选回收墓地6星以上不死族、从墓地有怪兽特招时进行不死族超量召唤）
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
-- 判断通召免解放效果的条件：免解放召唤且怪兽为5星以上，且场上有可用怪兽区域
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤手续要求的最小解放数为0、自身等级在5星以上且召唤者的怪兽区域有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤条件：卡组中除同名卡以外的6星以上且能送去墓地的不死族怪兽
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- ②效果的Target处理：检查卡组中是否存在满足条件的怪兽，设置送去墓地分类，并给对方玩家显示选择发动效果的提示
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在除同名卡以外的6星以上不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：包含从卡组将1张卡送去墓地分类
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家提示“对方选择了发动效果”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤条件：墓地中可以加入手卡的6星以上不死族怪兽
function s.thfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
-- ②效果的操作处理：从卡组选择1只满足条件的怪兽送去墓地；成功送墓后，可选择从墓地将1只6星以上的不死族怪兽加入手卡
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只除同名卡以外的6星以上不死族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选择的卡因效果送去墓地且该卡已到达墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取墓地中符合条件且不受「王家长眠之谷」影响的6星以上不死族怪兽组
		local gg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 询问玩家是否要将墓地的怪兽加入手卡
		if gg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否加入手卡？"
			-- 中断效果处理，使后续的回收手牌动作与前文送墓不同时处理
			Duel.BreakEffect()
			-- 设置选择提示：请选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=gg:Select(tp,1,1,nil)
			-- 为选中的卡片高亮显示选择框
			Duel.HintSelection(sg)
			-- 将选中的怪兽因效果加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
-- 过滤条件：从墓地特殊召唤成功的原本为怪兽类型的卡片
function s.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断发动条件：从墓地有怪兽特殊召唤且排除自身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：可以进行超量召唤的不死族超量怪兽
function s.xyzfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsXyzSummonable(nil)
end
-- ③效果的Target处理：检查额外卡组是否存在可以超量召唤的不死族超量怪兽，设置特殊召唤分类，并给对方显示提示
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断额外卡组中是否存在可以超量召唤的不死族超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息：包含从额外卡组特殊召唤1张卡分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示“对方选择了发动效果”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的操作处理：选择并进行1只不死族超量怪兽的超量召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有可以超量召唤的不死族超量怪兽
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 设置选择提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 进行1只不死族超量怪兽的超量召唤
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
