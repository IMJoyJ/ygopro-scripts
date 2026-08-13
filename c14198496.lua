--ミスティック・パイパー
-- 效果：
-- 把这张卡解放发动。从自己卡组抽1张卡。这个效果抽到的卡给双方确认，1星怪兽的场合，自己再抽1张卡。「神秘之吹笛人」的效果1回合只能使用1次。
function c14198496.initial_effect(c)
	-- 对应效果原文：把这张卡解放发动。从自己卡组抽1张卡。这个效果抽到的卡给双方确认，1星怪兽的场合，自己再抽1张卡。「神秘之吹笛人」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14198496,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,14198496)
	e1:SetCost(c14198496.cost)
	e1:SetTarget(c14198496.target)
	e1:SetOperation(c14198496.operation)
	c:RegisterEffect(e1)
end
-- 费用函数：效果发动前先检查此卡是否满足可解放条件；实际发动时以解放此卡作为代价。
function c14198496.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放，作为发动效果的代价（REASON_COST），解放操作不检查卡片是否受效果影响。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标函数：设定效果发动条件，确认自己可以抽1张卡，并登记本次效果的操作信息。
function c14198496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认己方不存在不能抽卡的限制，可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：本次效果分类为抽卡（CATEGORY_DRAW），让己方抽1张，具体抽到的卡在效果处理时确定，故targets参数传nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：自己抽1张卡；若抽卡成功则向对手展示该卡；若该卡是1星怪兽，则错开时点再抽1张；最后洗切手卡。
function c14198496.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因让己方抽1张卡，并将实际抽到的卡数存入ct。
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	-- 获取上一次操作（抽卡）实际抽到的卡组，并取出第一张作为抽到的那张卡dc。
	local dc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡dc给对手（1-tp）确认。
	Duel.ConfirmCards(1-tp,dc)
	if dc:IsLevel(1) then
		-- 中断当前效果链，使后续追加抽卡作为独立处理，以正确产生时点，避免漏掉“抽卡后”的诱发时点。
		Duel.BreakEffect()
		-- 由于抽到的卡是1星怪兽，追加再抽1张卡（同样作为效果抽卡）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	-- 抽卡完成后洗切手卡，重置手卡顺序相关状态。
	Duel.ShuffleHand(tp)
end
