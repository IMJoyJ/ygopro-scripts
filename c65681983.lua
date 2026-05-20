--抹殺の指名者
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1个卡名才能发动。宣言的1张卡从卡组除外。这个回合中，这个效果除外的卡以及原本卡名和那张卡相同的卡的效果无效化。
function c65681983.initial_effect(c)
	-- ①：宣言1个卡名才能发动。宣言的1张卡从卡组除外。这个回合中，这个效果除外的卡以及原本卡名和那张卡相同的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65681983+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c65681983.target)
	e1:SetOperation(c65681983.activate)
	c:RegisterEffect(e1)
end
-- 效果的发动准备与宣言卡名处理
function c65681983.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身卡组是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	-- 获取自身卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local ag=Group.CreateGroup()
	local codes={}
	-- 遍历卡组中的所有卡片
	for c in aux.Next(g) do
		local code=c:GetCode()
		if not ag:IsExists(Card.IsCode,1,nil,code) then
			ag:AddCard(c)
			table.insert(codes,code)
		end
	end
	table.sort(codes)
	local afilter={codes[1],OPCODE_ISCODE}
	if #codes>1 then
		for i=2,#codes do
			table.insert(afilter,codes[i])
			table.insert(afilter,OPCODE_ISCODE)
			table.insert(afilter,OPCODE_OR)
		end
	end
	-- 提示玩家宣言一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家从自身卡组存在的卡片中宣言一个卡名
	local ac=Duel.AnnounceCard(tp,table.unpack(afilter))
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 将宣言的卡名保存为效果的目标参数
	Duel.SetTargetParam(ac)
	-- 设置操作信息为发动时需要宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	-- 设置操作信息为从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤自身卡组中与宣言卡名相同且可以除外的卡
function c65681983.filter(c,code)
	return c:IsAbleToRemove() and c:IsCode(code)
end
-- 效果处理，将宣言的卡除外，并注册使该卡及同名卡效果无效的三个全局效果
function c65681983.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时宣言的卡名
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1张与宣言卡名相同的卡
	local tc=Duel.SelectMatchingCard(tp,c65681983.filter,tp,LOCATION_DECK,0,1,1,nil,ac):GetFirst()
	-- 成功将该卡表侧表示除外的场合
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		local c=e:GetHandler()
		-- 这个回合中，这个效果除外的卡以及原本卡名和那张卡相同的卡的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e1:SetTarget(c65681983.distg1)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使场上同名卡效果无效化的效果
		Duel.RegisterEffect(e1,tp)
		-- 这个回合中，这个效果除外的卡以及原本卡名和那张卡相同的卡的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(c65681983.discon)
		e2:SetOperation(c65681983.disop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在连锁处理时使同名卡发动效果无效化的效果
		Duel.RegisterEffect(e2,tp)
		-- 这个回合中，这个效果除外的卡以及原本卡名和那张卡相同的卡的效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(c65681983.distg2)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使同名陷阱怪兽效果无效化的效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 过滤场上与除外卡片原本卡名相同的魔法·陷阱卡，以及原本卡名相同且具有效果的怪兽卡
function c65681983.distg1(e,c)
	local tc=e:GetLabelObject()
	if c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
	else
		return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
	end
end
-- 过滤场上与除外卡片原本卡名相同的陷阱怪兽
function c65681983.distg2(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 检查发动效果的卡片原本卡名是否与除外卡片相同
function c65681983.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 无效该连锁的效果
function c65681983.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果
	Duel.NegateEffect(ev)
end
