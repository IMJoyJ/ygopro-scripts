--魔界劇団カーテン・ライザー
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果在决斗中只能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击力上升1100。
-- ②：1回合1次，从卡组把1张「魔界台本」魔法卡送去墓地才能发动。从自己的额外卡组把1只表侧表示的「魔界剧团」灵摆怪兽加入手卡。
function c44179224.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性（灵摆召唤、灵摆区发动等），使其能作为灵摆卡在灵摆区发动并拥有灵摆效果。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果在决斗中只能使用1次。①：自己场上没有怪兽存在的场合才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44179224,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,44179224+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c44179224.spcon)
	e1:SetTarget(c44179224.sptg)
	e1:SetOperation(c44179224.spop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】①：自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击力上升1100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(1100)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c44179224.atkcon)
	c:RegisterEffect(e2)
	-- 【怪兽效果】②：1回合1次，从卡组把1张「魔界台本」魔法卡送去墓地才能发动。从自己的额外卡组把1只表侧表示的「魔界剧团」灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44179224,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c44179224.thcost)
	e3:SetTarget(c44179224.thtg)
	e3:SetOperation(c44179224.thop)
	c:RegisterEffect(e3)
end
-- 灵摆效果的发动条件判断函数：检查自己的怪兽区域是否没有怪兽，若没有则满足‘自己场上没有怪兽存在’的发动条件。
function c44179224.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上怪兽区卡的数量，并判断是否为0（即自己场上没有怪兽）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 灵摆效果的目标函数：在发动时确认自己场上存在可用的怪兽区空格，且这张卡能够被特殊召唤；若可发动则设定操作信息。
function c44179224.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性的检查：确认己方场上至少有1个可用怪兽区域，以便后续特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：效果分类为特殊召唤，对象为本卡，数量为1，用于让其他卡片响应（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果处理时的操作函数：若这张卡仍与所发动的效果保持关联，则将其特殊召唤到自己场上。
function c44179224.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示（攻击表示）特殊召唤到其控制者的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力上升效果的条件判断函数：检查自己场上是否存在这张卡以外的怪兽，若不存在则条件满足。
function c44179224.atkcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 统计己方怪兽区域除这张卡以外的怪兽数量，并判断是否为0（即没有其他怪兽）。
	return Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,c)==0
end
-- cost筛选函数：检索卡组中的魔法卡，要求是「魔界台本」字段且可以作为cost送去墓地。
function c44179224.thcfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x20ec) and c:IsAbleToGraveAsCost()
end
-- cost执行函数：先确认卡组中存在符合条件的「魔界台本」魔法卡，然后让玩家选择1张，将其作为cost送去墓地。
function c44179224.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost合法性检查阶段，确认卡组中是否存在至少1张可作为cost的「魔界台本」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c44179224.thcfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 发送UI提示，告知玩家当前正在选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张满足条件的「魔界台本」魔法卡作为cost。
	local g=Duel.SelectMatchingCard(tp,c44179224.thcfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡作为cost送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索目标的筛选函数：要求卡为表侧表示、属于「魔界剧团」字段、是灵摆怪兽且能够加入手卡。
function c44179224.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 发动目标函数：确认额外卡组存在符合条件的表侧表示「魔界剧团」灵摆怪兽，并设置操作信息为加入手卡。
function c44179224.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性阶段，确认自己的额外卡组中是否存在至少1只符合条件的表侧表示「魔界剧团」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44179224.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置本次连锁的操作信息：将要从额外卡组把1只怪兽加入手卡，目标位置为额外卡组（处理时再选择具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：从额外卡组选择1只符合条件的「魔界剧团」灵摆怪兽加入手卡，并向对方玩家确认。
function c44179224.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送UI提示，告知玩家当前正在选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的额外卡组选择1只满足条件的表侧表示「魔界剧团」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c44179224.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（不计入对方手卡），原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
