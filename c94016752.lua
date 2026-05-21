--深淵の宣告者
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上有表侧表示怪兽存在的场合，支付1500基本分，宣言种族和属性各1个才能发动。宣言的种族·属性的怪兽在对方场上表侧表示存在的场合，对方必须把那之内的1只送去墓地。这个回合，对方不能把那只怪兽以及那些同名怪兽的怪兽效果发动。
function c94016752.initial_effect(c)
	-- ①：对方场上有表侧表示怪兽存在的场合，支付1500基本分，宣言种族和属性各1个才能发动。宣言的种族·属性的怪兽在对方场上表侧表示存在的场合，对方必须把那之内的1只送去墓地。这个回合，对方不能把那只怪兽以及那些同名怪兽的怪兽效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,94016752+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c94016752.cost)
	e1:SetTarget(c94016752.target)
	e1:SetOperation(c94016752.activate)
	c:RegisterEffect(e1)
end
-- 检查并支付发动Cost（1500基本分）
function c94016752.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动玩家是否能支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 检查发动条件（对方场上有表侧表示怪兽），并让发动玩家宣言1个属性和1个种族
function c94016752.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,1-tp,LOCATION_MZONE,0,1,nil) end
	-- 提示发动玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让发动玩家从所有属性中宣言1个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	-- 提示发动玩家选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让发动玩家从所有种族中宣言1个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(att)
	-- 将宣言的种族作为效果的目标参数保存，以便在效果处理时获取
	Duel.SetTargetParam(rc)
end
-- 过滤对方场上表侧表示、且满足宣言种族和属性、且能送去墓地的怪兽
function c94016752.tgfilter(c,rc,att)
	return c:IsFaceup() and c:IsRace(rc) and c:IsAttribute(att) and c:IsAbleToGrave()
end
-- 效果处理：获取宣言的属性和种族，让对方选择1只满足条件的怪兽送去墓地，并限制该怪兽同名卡的效果发动
function c94016752.activate(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	-- 获取在发动时宣言并保存的种族参数
	local rc=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取对方场上满足宣言种族和属性的表侧表示怪兽组
	local g=Duel.GetMatchingGroup(c94016752.tgfilter,1-tp,LOCATION_MZONE,0,nil,rc,att)
	if g:GetCount()>0 then
		-- 提示对方玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 为对方选择的怪兽显示被选中的动画效果
		Duel.HintSelection(sg)
		local code=sg:GetFirst():GetCode()
		-- 如果对方成功将选择的怪兽因规则送去墓地
		if Duel.SendtoGrave(sg,REASON_RULE,1-tp)~=0 then
			-- 这个回合，对方不能把那只怪兽以及那些同名怪兽的怪兽效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(0,1)
			e1:SetValue(c94016752.aclimit)
			e1:SetLabel(code)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将限制效果注册给发动玩家，使其在全局生效
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 限制效果的过滤函数，判定是否为被送去墓地怪兽的同名怪兽的怪兽效果
function c94016752.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
