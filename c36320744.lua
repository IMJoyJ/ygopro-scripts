--聖剣を巡る王姫アンジェリカ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张有「焰圣骑士帝-查理」的卡名记述的卡或者「象牙角笛」加入手卡。
-- ②：场上的这张卡成为攻击·效果的对象时才能发动。从卡组把1只战士族·炎属性怪兽送去墓地，这张卡直到结束阶段除外。那之后，可以从卡组·额外卡组把1只「罗兰」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置卡片的代码列表、同调召唤程序、复活限制，并注册两个效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着卡号77656797的卡片
	aux.AddCodeList(c,77656797)
	-- 设置该卡的同调召唤程序为调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张有「焰圣骑士帝-查理」的卡名记述的卡或者「象牙角笛」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡成为攻击·效果的对象时才能发动。从卡组把1只战士族·炎属性怪兽送去墓地，这张卡直到结束阶段除外。那之后，可以从卡组·额外卡组把1只「罗兰」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡除外"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e3)
end
-- 检索过滤函数，用于筛选卡组中包含「焰圣骑士帝-查理」或「象牙角笛」的卡
function s.thfilter(c)
	-- 返回满足条件的卡，即卡号为55749927或记载着77656797的卡，并且可以加入手牌
	return (c:IsCode(55749927) or aux.IsCodeListed(c,77656797)) and c:IsAbleToHand()
end
-- 设置检索效果的发动条件，检查卡组中是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并把卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方能看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断效果是否发动的条件，判断该卡是否成为攻击或效果的目标
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 攻击目标过滤函数，筛选卡组中战士族·炎属性的怪兽
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave()
end
-- 设置效果目标的处理函数，检查是否可以除外自身并检索卡组中的战士族·炎属性怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以除外自身并检索卡组中的战士族·炎属性怪兽
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组送去墓地1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示将自身除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 特殊召唤过滤函数，筛选卡组或额外卡组中「罗兰」怪兽
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x148) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		-- 检查玩家场上是否有足够的位置特殊召唤来自卡组的怪兽
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		-- 检查玩家场上是否有足够的位置特殊召唤来自额外卡组的怪兽
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
-- 效果处理函数，选择并送去墓地的卡，然后除外自身并可能特殊召唤「罗兰」怪兽
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否满足效果处理条件，即选中的卡被送去墓地且在墓地
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			local fid=c:GetFieldID()
			-- 将自身以REASON_TEMPORARY原因除外
			if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
				if c:GetOriginalCode()==id then
					c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
					-- 设置一个在结束阶段自动返回场上的效果
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetLabel(fid)
					e1:SetLabelObject(c)
					e1:SetCountLimit(1)
					e1:SetCondition(s.retcon)
					e1:SetOperation(s.retop)
					e1:SetReset(RESET_PHASE+PHASE_END)
					-- 注册该效果到全局环境
					Duel.RegisterEffect(e1,tp)
				end
				-- 检查卡组或额外卡组中是否存在满足条件的「罗兰」怪兽
				if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
					-- 询问玩家是否要特殊召唤「罗兰」怪兽
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组·额外卡组特殊召唤？"
					-- 提示玩家选择要特殊召唤的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					-- 从卡组或额外卡组中选择满足条件的卡
					local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
					-- 中断当前效果处理，使之后的效果视为不同时处理
					Duel.BreakEffect()
					-- 将选中的卡特殊召唤到场上
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 判断是否返回场上的条件，检查flag是否匹配
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 返回场上的处理函数，将自身返回到场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
