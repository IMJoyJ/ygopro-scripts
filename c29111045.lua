--百鬼羅刹大収監
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。从卡组把1只「哥布林」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
-- ②：自己或对方的怪兽的攻击宣言时，把墓地的这张卡除外，把自己场上的「哥布林」超量怪兽的超量素材任意数量取除才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降取除数量×1000。
local s,id,o=GetID()
-- 创建并注册这张卡的①②两个效果：e1为①效果的魔法卡发动效果（自己场上1只怪兽解放后从卡组特殊召唤「哥布林」怪兽），e2为②效果的墓地诱发效果（攻击宣言时除外自身并取除超量素材，降低对方全场怪兽攻击力）；分别设置各自的发动时机、次数限制、代价、发动条件和处理函数。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上1只怪兽解放才能发动。从卡组把1只「哥布林」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己或对方的怪兽的攻击宣言时，把墓地的这张卡除外，把自己场上的「哥布林」超量怪兽的超量素材任意数量取除才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降取除数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力下降"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价处理：先检查能否支付（自己场上有可解放的怪兽且解放后仍有空余怪兽区），然后选择1只怪兽解放作为COST。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己场上存在至少1只满足解放条件的怪兽（通过costfilter过滤），即是否能够支付解放代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp) end
	-- 选择要解放的1只怪兽（使用costfilter过滤，要求解放后自己场上仍有空位）作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,tp)
	-- 将选择的怪兽解放（REASON_COST，作为代价处理）。
	Duel.Release(g,REASON_COST)
end
-- ①效果的解放代价过滤器：检查候选怪兽被解放后，自己场上是否仍有可用的怪兽区域（这是为了确保解放后能够进行后续的特殊召唤）。
function s.costfilter(c,tp)
	-- 判断解放该怪兽后，自己场上至少还有1个怪兽区可用。
	return Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的特殊召唤过滤器：候选卡必须属「哥布林」系列，并且能够被玩家tp以效果形式特殊召唤（不检查召唤条件，不检查苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xac) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时的目标选择条件：检查卡组中是否存在至少1只符合spfilter的「哥布林」怪兽，并设置本次特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认卡组中存在至少1只可被特殊召唤的「哥布林」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次连锁将进行1只怪兽的特殊召唤，特殊召唤来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时的实际执行：若能空出怪兽区，则从卡组选择1只符合条件的「哥布林」怪兽特殊召唤；成功召唤后，为该怪兽附加‘这个回合不能攻击’的永续效果（持续到回合结束）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有可用怪兽区，则不能进行特殊召唤，效果处理直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示让玩家选择要特殊召唤的卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足spfilter条件的「哥布林」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择到了怪兽，则将其以表侧表示特殊召唤（先执行SpecialSummonStep预处理，判断是否成功）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤步骤（Duel.SpecialSummonComplete），结束本次特殊召唤处理并触发相关时点。
	Duel.SpecialSummonComplete()
end
-- ②效果的素材来源怪兽过滤器：自己场上表侧表示的「哥布林」超量怪兽（拥有超量素材）。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and c:IsType(TYPE_XYZ)
end
-- ②效果的发动代价处理：收集自己场上所有「哥布林」超量怪兽及其所有超量素材；检查存在可取素材且能将墓地这张卡除外；实际除外自身，让玩家选择任意数量的素材送入墓地作为取除代价，记录取除数量；最后为被取除素材的超量怪兽触发取除素材时点。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足atkfilter条件的「哥布林」超量怪兽的集合。
	local mg=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	local xg=Group.FromCards()
	local cg=Group.FromCards()
	-- 遍历这些超量怪兽，逐一收集它们附带的超量素材。
	for tc in aux.Next(mg) do
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			cg:AddCard(tc)
			-- 遍历当前超量怪兽的所有超量素材，将其加入总素材集合xg，以便后续选择。
			for oc in aux.Next(og) do
				xg:AddCard(oc)
			end
		end
	end
	-- 合法性检查：确认存在至少1个可取的超量素材，并且能支付‘把墓地的这张卡除外’的代价。
	if chk==0 then return xg:GetCount()>0 and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
	-- 实际把墓地中的这张卡除外作为发动代价。
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 让玩家从所有可选超量素材中任意选择1至全部数量的素材（任意数量），作为本次取除的素材。
	local sg=xg:FilterSelect(tp,aux.TRUE,1,xg:GetCount(),nil)
	local tg=Group.CreateGroup()
	-- 遍历之前记录的所有拥有素材的超量怪兽（cg），用于确定哪些怪兽实际被取除了素材。
	for tc in aux.Next(cg) do
		local vg=tc:GetOverlayGroup()
		-- 遍历玩家已选择的素材，判断是否属于当前怪兽的超量素材。
		for c in aux.Next(sg) do
			if vg:IsContains(c) then
				tg:AddCard(tc)
				break
			end
		end
	end
	-- 将选中的超量素材送入墓地（即取除超量素材），并记录实际送入的素材数量。
	local at=Duel.SendtoGrave(sg,REASON_COST)
	-- 遍历所有被取除了素材的超量怪兽（tg），逐一触发它们相关的取除素材时点。
	for tc in aux.Next(tg) do
		-- 为每只被取除素材的超量怪兽触发EVENT_DETACH_MATERIAL事件，使依赖取除素材的诱发效果能够正确发动。
		Duel.RaiseSingleEvent(tc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
	e:SetLabel(at)
end
-- ②效果的发动条件函数：在攻击宣言时，确认对方场上有表侧表示怪兽存在（用于后续降低其攻击力）。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认对方场上有至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ②效果处理时的实际执行：根据cost阶段记录在e上的取除素材数量，将对方场上全部表侧表示怪兽的攻击力下降（数量×1000），直到回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()*1000
	-- 获取对方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上的表侧表示怪兽，逐只附加攻击力下降效果。
	for tc in aux.Next(g) do
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降取除数量×1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-atk)
		tc:RegisterEffect(e1)
	end
end
