--竜剣士マジェスティP
-- 效果：
-- ←2 【灵摆】 2→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「龙剑士」卡或「威风妖怪」卡存在的场合才能发动。原本卡名和那张卡不同的1只「龙剑士」灵摆怪兽从卡组加入手卡。那之后，可以把自己的灵摆区域1张卡破坏。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「威风妖怪」卡使用。这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。这个回合中，自己场上的「龙剑士」怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
-- ②：这张卡灵摆召唤或者用「龙剑士」卡的效果特殊召唤的场合才能发动。从卡组把1张场地魔法卡加入手卡。那之后，选自己1张手卡丢弃。
function c92332424.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域有「龙剑士」卡或「威风妖怪」卡存在的场合才能发动。原本卡名和那张卡不同的1只「龙剑士」灵摆怪兽从卡组加入手卡。那之后，可以把自己的灵摆区域1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92332424,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,92332424)
	e1:SetCondition(c92332424.srcon)
	e1:SetTarget(c92332424.srtg)
	e1:SetOperation(c92332424.srop)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。这个回合中，自己场上的「龙剑士」怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92332424,2))  --"把这张卡从手卡丢弃"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c92332424.cost)
	e2:SetTarget(c92332424.target)
	e2:SetOperation(c92332424.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡灵摆召唤或者用「龙剑士」卡的效果特殊召唤的场合才能发动。从卡组把1张场地魔法卡加入手卡。那之后，选自己1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92332424,3))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,92332425)
	e3:SetCondition(c92332424.thcon)
	e3:SetTarget(c92332424.thtg)
	e3:SetOperation(c92332424.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：属于「龙剑士」或「威风妖怪」系列的卡片
function c92332424.cfilter(c)
	return c:IsSetCard(0xc7,0xd0)
end
-- 灵摆效果的发动条件：另一边的自己的灵摆区域有「龙剑士」卡或「威风妖怪」卡存在
function c92332424.srcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己另一边的灵摆区域是否存在「龙剑士」卡或「威风妖怪」卡
	return Duel.IsExistingMatchingCard(c92332424.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤条件：原本卡名与另一边灵摆区域的卡不同、属于「龙剑士」系列的灵摆怪兽，且能加入手牌
function c92332424.srfilter(c,oc)
	return not c:IsOriginalCodeRule(oc:GetOriginalCodeRule()) and c:IsSetCard(0xc7) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果的发动准备（检查卡组中是否存在符合条件的卡，并设置检索操作信息）
function c92332424.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己另一边灵摆区域的卡
		local oc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,e:GetHandler())
		-- 检查卡组中是否存在原本卡名与另一边灵摆卡不同且可以加入手牌的「龙剑士」灵摆怪兽
		return Duel.IsExistingMatchingCard(c92332424.srfilter,tp,LOCATION_DECK,0,1,nil,oc)
	end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的处理：将符合条件的「龙剑士」灵摆怪兽加入手牌，之后可以破坏自己灵摆区域的1张卡
function c92332424.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己另一边灵摆区域的卡
	local oc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,e:GetHandler())
	if not oc then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只原本卡名与另一边灵摆卡不同的「龙剑士」灵摆怪兽
	local tc=Duel.SelectMatchingCard(tp,c92332424.srfilter,tp,LOCATION_DECK,0,1,1,nil,oc):GetFirst()
	-- 如果成功将选中的怪兽加入手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 获取自己灵摆区域的所有卡
		local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		-- 如果自己灵摆区域有卡，询问玩家是否选择其中1张破坏
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(92332424,1)) then  --"是否选自己的灵摆区域1张卡破坏？"
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果，使后续的破坏处理与加入手牌不视为同时处理
			Duel.BreakEffect()
			-- 为选中的卡显示被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 将选中的灵摆卡破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 怪兽效果①的发动成本：把这张卡从手牌丢弃
function c92332424.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动成本，将这张卡从手牌丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 怪兽效果①的发动准备（检查本回合是否已发动过该效果）
function c92332424.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合是否尚未注册过该效果的标识（确保一回合只能使用一次）
	if chk==0 then return Duel.GetFlagEffect(tp,92332424)==0 end
end
-- 怪兽效果①的效果处理：本回合中，自己场上的「龙剑士」怪兽不会被对方的效果破坏，且不能作为对方效果的对象
function c92332424.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，自己场上的「龙剑士」怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。②：这张卡灵摆召唤或者用「龙剑士」卡的效果特殊召唤的场合才能发动。从卡组把1张场地魔法卡加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c92332424.efftg)
	-- 设置不能成为对方卡的效果对象
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册不能成为效果对象的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方卡的效果破坏
	e2:SetValue(aux.indoval)
	-- 在全局环境中注册不会被效果破坏的效果
	Duel.RegisterEffect(e2,tp)
	-- 为玩家注册全局标识，用于限制该效果一回合只能使用一次
	Duel.RegisterFlagEffect(tp,92332424,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：适用于自己场上的「龙剑士」怪兽
function c92332424.efftg(e,c)
	return c:IsSetCard(0xc7)
end
-- 怪兽效果②的发动条件：这张卡灵摆召唤成功，或者用「龙剑士」卡的效果特殊召唤成功
function c92332424.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) or c:IsSpecialSummonSetCard(0xc7)
end
-- 过滤条件：属于场地魔法卡，且能加入手牌
function c92332424.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 怪兽效果②的发动准备（检查卡组中是否存在场地魔法卡，并设置检索和丢弃手牌的操作信息）
function c92332424.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92332424.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁处理的操作信息：丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 怪兽效果②的效果处理：从卡组将1张场地魔法卡加入手牌，之后选自己1张手牌丢弃
function c92332424.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,c92332424.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 如果成功将选中的场地魔法卡加入手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使后续的丢弃手牌处理与加入手牌不视为同时处理
		Duel.BreakEffect()
		-- 让玩家选择自己1张手牌丢弃
		Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)
	end
end
