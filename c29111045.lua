--百鬼羅刹大収監
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。从卡组把1只「哥布林」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
-- ②：自己或对方的怪兽的攻击宣言时，把墓地的这张卡除外，把自己场上的「哥布林」超量怪兽的超量素材任意数量取除才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降取除数量×1000。
local s,id,o=GetID()
-- 注册两个效果：①特殊召唤效果和②攻击力下降效果
function s.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。从卡组把1只「哥布林」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
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
-- 检查并选择1张可解放的怪兽进行解放作为发动①的代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp) end
	-- 选择1张可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 判断怪兽是否满足解放条件
function s.costfilter(c,tp)
	-- 判断场上是否有空怪兽区
	return Duel.GetMZoneCount(tp,c)>0
end
-- 筛选满足条件的哥布林怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xac) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足特殊召唤条件并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的哥布林怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作并设置不能攻击效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的哥布林怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1张哥布林怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置特殊召唤的哥布林怪兽不能攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 筛选场上满足条件的哥布林超量怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xac) and c:IsType(TYPE_XYZ)
end
-- 处理②效果的发动代价：将场上哥布林超量怪兽的超量素材移除作为代价
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有哥布林超量怪兽
	local mg=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	local xg=Group.FromCards()
	local cg=Group.FromCards()
	-- 遍历所有哥布林超量怪兽
	for tc in aux.Next(mg) do
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			cg:AddCard(tc)
			-- 遍历每个超量怪兽的超量素材
			for oc in aux.Next(og) do
				xg:AddCard(oc)
			end
		end
	end
	-- 检查是否满足发动②效果的代价条件
	if chk==0 then return xg:GetCount()>0 and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
	-- 执行将自身除外作为代价
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 选择要移除的超量素材
	local sg=xg:FilterSelect(tp,aux.TRUE,1,xg:GetCount(),nil)
	local tg=Group.CreateGroup()
	-- 遍历所有哥布林超量怪兽
	for tc in aux.Next(cg) do
		local vg=tc:GetOverlayGroup()
		-- 遍历选择的超量素材
		for c in aux.Next(sg) do
			if vg:IsContains(c) then
				tg:AddCard(tc)
				break
			end
		end
	end
	-- 将选择的超量素材移除至墓地
	local at=Duel.SendtoGrave(sg,REASON_COST)
	-- 遍历需要触发移除素材事件的哥布林超量怪兽
	for tc in aux.Next(tg) do
		-- 触发移除素材事件
		Duel.RaiseSingleEvent(tc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
	e:SetLabel(at)
end
-- 设置②效果的目标
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在对方场上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 执行②效果：使对方场上所有怪兽攻击力下降
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()*1000
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上的所有怪兽
	for tc in aux.Next(g) do
		-- 设置对方怪兽攻击力下降的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-atk)
		tc:RegisterEffect(e1)
	end
end
