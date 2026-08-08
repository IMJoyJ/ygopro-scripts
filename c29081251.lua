--死相の冥鑑ヒュブロ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。除「死相之冥鉴 许布洛」外的1只6星以上的不死族怪兽从卡组送去墓地。那之后，可以从自己墓地把1只6星以上的不死族怪兽加入手卡。
-- ③：这张卡在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合才能发动。进行1只不死族超量怪兽的超量召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：不用解放召唤、送去墓地并加入手牌、从墓地特殊召唤时进行超量召唤
function s.initial_effect(c)
	-- 效果①：这张卡可以不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- 效果②：这张卡召唤·特殊召唤的场合才能发动。除「死相之冥鉴 许布洛」外的1只6星以上的不死族怪兽从卡组送去墓地。那之后，可以从自己墓地把1只6星以上的不死族怪兽加入手卡
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
	-- 效果③：这张卡在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合才能发动。进行1只不死族超量怪兽的超量召唤
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
-- 判断是否满足不用解放召唤条件
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足条件时返回true，表示可以不用解放作召唤
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤函数：用于筛选除自身外的6星以上不死族怪兽
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- 设置效果②的目标，检查卡组是否存在符合条件的怪兽并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否卡组存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将要送去墓地的卡的类别信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 提示对方玩家该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤函数：用于筛选6星以上不死族可加入手牌的怪兽
function s.thfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
-- 执行效果②的操作，选择并送去墓地，再选择是否加入手牌
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张符合条件的卡送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认卡已成功送去墓地后执行后续操作
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取满足条件的可加入手牌的怪兽组（排除王家长眠之谷影响）
		local gg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 判断是否有符合条件的怪兽且玩家选择加入手牌
		if gg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否加入手卡？"
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=gg:Select(tp,1,1,nil)
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 将选定的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
-- 过滤函数：用于筛选从墓地特殊召唤的怪兽
function s.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断是否满足效果③发动条件，即是否有从墓地特殊召唤的怪兽且不包含自身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数：用于筛选可进行超量召唤的不死族怪兽
function s.xyzfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsXyzSummonable(nil)
end
-- 设置效果③的目标，检查额外卡组是否存在符合条件的怪兽并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否额外卡组存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置将要特殊召唤的卡的类别信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 提示对方玩家该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行效果③的操作，选择并进行超量召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的可超量召唤的怪兽组
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 对选定的卡进行超量召唤
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
