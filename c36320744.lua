--聖剣を巡る王姫アンジェリカ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张有「焰圣骑士帝-查理」的卡名记述的卡或者「象牙角笛」加入手卡。
-- ②：场上的这张卡成为攻击·效果的对象时才能发动。从卡组把1只战士族·炎属性怪兽送去墓地，这张卡直到结束阶段除外。那之后，可以从卡组·额外卡组把1只「罗兰」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化「围绕圣剑的王姬 安洁莉卡」(36320744)：记录「焰圣骑士帝-查理」卡名、设置同调召唤手续与苏生限制，并注册①检索与②被选为对象时堆墓暂除且特召「罗兰」效果
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「焰圣骑士帝-查理」(77656797)的卡名
	aux.AddCodeList(c,77656797)
	-- 设置同调召唤手续：1只调整＋1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤的场合才能发动。从卡组把1张有「焰圣骑士帝-查理」的卡名记述的卡或者「象牙角笛」加入手卡。
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
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 过滤函数：筛选卡组中「象牙角笛」(55749927)或记述有「焰圣骑士帝-查理」(77656797)卡名且可加入手卡的卡片
function s.thfilter(c)
	-- 判断卡片是否为「象牙角笛」(55749927)或记载了「焰圣骑士帝-查理」(77656797)卡名，且能够加入手卡
	return (c:IsCode(55749927) or aux.IsCodeListed(c,77656797)) and c:IsAbleToHand()
end
-- 效果①的Target函数：检测己方卡组是否存在符合检索条件的卡片，并设置从卡组把1张卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1张符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从己方卡组把1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation函数：从卡组选择1张「象牙角笛」或记述有「焰圣骑士帝-查理」的卡加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要加入手卡的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 以效果将选中的卡片加入持有者（己方）手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的Condition函数：检查成为攻击或效果对象的卡片集合eg中是否包含这张卡
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 过滤函数：筛选卡组中炎属性、战士族且可以送去墓地的怪兽
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave()
end
-- 效果②的Target函数：检测这张卡是否可以除外且卡组存在炎属性战士族怪兽，并设置堆墓与除外自身的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动检测时确认这张卡可以被除外且己方卡组中存在至少1只炎属性·战士族怪兽
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从己方卡组把1只怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置将场上的这张卡除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 过滤函数：筛选卡组或额外卡组中属于「罗兰」(0x148)字段、可特殊召唤且对应位置有足够空位的怪兽
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x148) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		-- 若候选怪兽位于卡组，检查己方主要怪兽区是否有可用空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		-- 若候选怪兽位于额外卡组，检查己方能从额外卡组特召怪兽的可用空位是否足够
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
-- 效果②的Operation函数：从卡组将1只炎属性战士族怪兽送墓，将这张卡暂时除外至结束阶段，随后可从卡组或额外卡组特召1只「罗兰」怪兽
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要送去墓地的怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组中选择1只炎属性·战士族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 以效果将选中的炎属性·战士族怪兽送去墓地，并确认其成功进入墓地
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			local fid=c:GetFieldID()
			-- 尝试将与效果关联的这张卡以效果暂时除外（REASON_TEMPORARY）
			if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
				if c:GetOriginalCode()==id then
					c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
					-- 这张卡直到结束阶段除外。那之后，可以从卡组·额外卡组把1只「罗兰」怪兽特殊召唤。
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetLabel(fid)
					e1:SetLabelObject(c)
					e1:SetCountLimit(1)
					e1:SetCondition(s.retcon)
					e1:SetOperation(s.retop)
					e1:SetReset(RESET_PHASE+PHASE_END)
					-- 为己方玩家注册在当前回合结束阶段将暂时除外的这张卡返回场上的延迟效果
					Duel.RegisterEffect(e1,tp)
				end
				-- 检查己方卡组或额外卡组中是否存在至少1只可特殊召唤的「罗兰」怪兽
				if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
					-- 询问己方玩家是否要从卡组或额外卡组特殊召唤1只「罗兰」怪兽
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组·额外卡组特殊召唤？"
					-- 向己方玩家发送选择要特殊召唤的「罗兰」怪兽提示
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					-- 从己方卡组或额外卡组中选择1只符合条件的「罗兰」怪兽
					local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
					-- 中断当前处理步骤，使后续「罗兰」怪兽的特殊召唤与前面的送墓、除外视为不同时处理（“那之后”）
					Duel.BreakEffect()
					-- 将选中的「罗兰」怪兽以表侧表示特殊召唤到己方场上
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 归还效果的Condition函数：检查LabelObject中的这张卡是否仍保留匹配的暂时除外标记fid，否则重置并销毁该效果
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 归还效果的Operation函数：在结束阶段将暂时除外的这张卡返回原控制者场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的这张卡返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
