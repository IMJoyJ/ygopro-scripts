--聖剣を巡る王姫アンジェリカ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张有「焰圣骑士帝-查理」的卡名记述的卡或者「象牙角笛」加入手卡。
-- ②：场上的这张卡成为攻击·效果的对象时才能发动。从卡组把1只战士族·炎属性怪兽送去墓地，这张卡直到结束阶段除外。那之后，可以从卡组·额外卡组把1只「罗兰」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册同调召唤手续（调整＋调整以外怪兽1只以上）、①在特殊召唤成功时检索「焰圣骑士帝-查理」或「象牙角笛」的效果、②在成为攻击/效果对象时发动送墓战士族炎属性+自身暂时除外+可特召「罗兰」的效果，并让②同时应对成为攻击对象和成为效果对象两种时点。
function s.initial_effect(c)
	-- 将77656797（焰圣骑士帝-查理）登记到这张卡的卡名记述列表中，使检索时可用aux.IsCodeListed(c,77656797)判断卡名是否记述了该卡。
	aux.AddCodeList(c,77656797)
	-- 为这张卡追加同调召唤手续：调整1只＋调整以外怪兽1只以上。
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
-- 定义①的检索过滤器：卡名是「象牙角笛」（55749927），或者效果文本中记述了「焰圣骑士帝-查理」（77656797）的卡，并且能够加入手卡。
function s.thfilter(c)
	-- 检索条件的具体判断：满足卡名是象牙角笛 OR 记述有焰圣骑士帝-查理，且该卡当前可以加入手卡。
	return (c:IsCode(55749927) or aux.IsCodeListed(c,77656797)) and c:IsAbleToHand()
end
-- 定义①的发动目标函数：在发动时确认卡组存在检索对象，并设置本次操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在至少1张满足s.thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“从卡组检索1张卡加入手卡”（目标不确定所以传nil，数量1，位置为卡组），供后续时点/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①的效果处理：从卡组选出1张符合条件的卡加入手卡，并让对方确认加入手卡的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足s.thfilter的卡（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②的发动条件：成为攻击或效果对象的事件集合中包含这张卡自身，即这张卡被选择为攻击对象或效果对象时才能发动。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 定义送墓过滤器：战士族且炎属性的怪兽，且能够被效果送去墓地。
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave()
end
-- 定义②的发动目标函数：检查自身可除外且卡组存在符合条件的战士族炎属性怪兽，并设置送墓/除外的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- ②发动合法性检查：这张卡当前可以被除外，且卡组中存在至少1只战士族·炎属性怪兽可以送去墓地。
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“将从卡组把1只怪兽送去墓地”（不取对象，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息为“将这张卡自身除外”（目标为自身c，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 定义特殊召唤罗兰的过滤器：必须是「罗兰」系列怪兽（0x148），能够被这次效果特殊召唤；若从卡组特召要求主怪兽区有空位，若从额外卡组特召要求额外卡组怪兽能出场的空位。
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x148) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		-- 当从卡组特殊召唤时，检查玩家tp的主要怪兽区是否有空位。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		-- 当从额外卡组特殊召唤时，检查玩家tp的额外卡组怪兽可用出场空格数是否大于0。
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
-- 定义②的效果处理：先选择并送墓1只战士族·炎属性怪兽；成功后若这张卡仍与效果关联，则将其暂时除外并设置结束阶段返回，之后可选择从卡组·额外卡组特殊召唤1只「罗兰」怪兽。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只战士族·炎属性怪兽送去墓地。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 条件判断：选到了送墓对象且实际送墓成功，且该卡确实位于墓地时，才继续执行后续效果。
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			local fid=c:GetFieldID()
			-- 将这张卡以“暂时除外”方式除外，若除外成功则继续处理。
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
					-- 将结束阶段时使暂时除外的这张卡返回场上的持续效果注册到决斗中（效果所有者tp）。
					Duel.RegisterEffect(e1,tp)
				end
				-- 检查卡组·额外卡组中是否存在至少1只可以特殊召唤的「罗兰」怪兽，作为是否询问玩家特召的条件。
				if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
					-- 询问玩家是否从卡组·额外卡组特殊召唤「罗兰」怪兽。
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组·额外卡组特殊召唤？"
					-- 弹出选择提示：请选择要特殊召唤的卡。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					-- 从卡组·额外卡组选择1只满足条件的「罗兰」怪兽。
					local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
					-- 中断当前效果处理，使后续特殊召唤作为不同时处理，以避免错过时点。
					Duel.BreakEffect()
					-- 将选择的「罗兰」怪兽以表侧攻击表示特殊召唤到tp的场上（不检查召唤条件/苏生限制）。
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 定义结束阶段回归的持续效果条件：仅当这张卡仍带有与本次除外时记录的field id一致的标记（即没有被其他效果重置/变化）时，才允许返回；否则终止该效果。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 定义结束阶段回归的操作：把暂时除外的这张卡返回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行把暂时除外的这张卡返回场上的操作。
	Duel.ReturnToField(e:GetLabelObject())
end
