--海造賊－荘重のヨルズ号
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：宣言1个属性才能发动。这张卡回到持有者的额外卡组，把持有宣言的属性的「海造贼衍生物」（恶魔族·4星·攻/守0）在双方场上各1只守备表示特殊召唤。
-- 【怪兽效果】
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：对方对怪兽的特殊召唤成功的场合才能发动。从卡组把1张「海造贼」卡加入手卡。这张卡有「海造贼」卡装备的场合，可以再从卡组把1只「海造贼」怪兽特殊召唤。
-- ②：以自己墓地1张「海造贼」卡为对象才能发动。那张卡加入手卡，这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆属性、同调召唤手续、苏生限制以及三个效果的注册。
function s.initial_effect(c)
	-- 注册灵摆怪兽属性，但不注册默认的灵摆卡发动效果（因为有自定义的灵摆效果）。
	aux.EnablePendulumAttribute(c,false)
	-- 注册同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的灵摆效果1回合只能使用1次。①：宣言1个属性才能发动。这张卡回到持有者的额外卡组，把持有宣言的属性的「海造贼衍生物」（恶魔族·4星·攻/守0）在双方场上各1只守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：对方对怪兽的特殊召唤成功的场合才能发动。从卡组把1张「海造贼」卡加入手卡。这张卡有「海造贼」卡装备的场合，可以再从卡组把1只「海造贼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组把1张「海造贼」卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：以自己墓地1张「海造贼」卡为对象才能发动。那张卡加入手卡，这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 获取当前状态下，双方玩家都能合法特殊召唤该属性衍生物的所有属性组合。
function s.GetLegalAttributesOnly(tp)
	local a,attr=1,0
	while a<ATTRIBUTE_ALL do
		local check=true
		for p=0,1 do
			-- 检查玩家是否能将指定属性、种族、等级、攻守的衍生物以守备表示特殊召唤到指定玩家场上。
			if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x13f,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,a,POS_FACEUP_DEFENSE,p) then
				check=false
				break
			end
		end
		if check then
			attr=attr|a
		end
		a=a<<1
	end
	return attr
end
-- 灵摆效果①的启动与目标检查函数（Target）。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查此卡是否能回到额外卡组，以及自己场上是否有可用的怪兽区域。
		if not c:IsAbleToExtra() or Duel.GetMZoneCount(tp,c)<=0
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			or Duel.GetMZoneCount(1-tp,c,tp)<=0 or Duel.IsPlayerAffectedByEffect(tp,59822133) then
			return false
		end
		return s.GetLegalAttributesOnly(tp)~=0
	end
	-- 提示玩家选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可合法特招的属性中宣言1个属性。
	local attr=Duel.AnnounceAttribute(tp,1,s.GetLegalAttributesOnly(tp))
	-- 将宣言的属性保存为效果处理时的参数。
	Duel.SetTargetParam(attr)
	-- 设置操作信息：将这张卡回到额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置操作信息：生成衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：在双方场上特殊召唤共2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,0)
end
-- 灵摆效果①的效果处理函数（Operation）。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与效果相关，并将其回到持有者的额外卡组，若未成功回到额外卡组则结束处理。
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_EXTRA) then return end
	-- 获取之前宣言并保存的属性参数。
	local attr=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if not attr or attr==0
		-- 检查自己是否仍能特殊召唤该属性的衍生物。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x13f,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,attr,POS_FACEUP_DEFENSE,tp)
		-- 检查对方是否仍能特殊召唤该属性的衍生物。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x13f,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,attr,POS_FACEUP_DEFENSE,1-tp)
		-- 检查双方场上是否仍有可用的怪兽区域。
		or Duel.GetMZoneCount(tp,c)<=0 or Duel.GetMZoneCount(1-tp,c,tp)<=0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then
		return
	end
	-- 遍历双方玩家（当前回合玩家和对方玩家）。
	for p in aux.TurnPlayers() do
		-- 创建「海造贼衍生物」卡片实例。
		local token=Duel.CreateToken(tp,id+o)
		-- 把持有宣言的属性的「海造贼衍生物」（恶魔族·4星·攻/守0）在双方场上各1只守备表示特殊召唤。对方对怪兽的特殊召唤成功的场合才能发动。从卡组把1张「海造贼」卡加入手卡。这张卡有「海造贼」卡装备的场合，可以再从卡组把1只「海造贼」怪兽特殊召唤。以自己墓地1张「海造贼」卡为对象才能发动。那张卡加入手卡，这张卡在自己的灵摆区域放置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(attr)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1,true)
		-- 将衍生物以守备表示特殊召唤到玩家p的场上（分步处理）。
		Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成所有分步特殊召唤的处理。
	Duel.SpecialSummonComplete()
end
-- 怪兽效果①的触发条件：对方对怪兽的特殊召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤条件：卡名带有「海造贼」且能加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsAbleToHand()
end
-- 怪兽效果①的启动与目标检查函数（Target）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「海造贼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡名带有「海造贼」且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x13f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：自己场上表侧表示的「海造贼」装备卡。
function s.eqfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 怪兽效果①的效果处理函数（Operation）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「海造贼」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡加入手卡，并确认是否成功加入手卡。
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 检查这张卡是否有「海造贼」卡装备，以及自己场上是否有可用的怪兽区域。
		if e:GetHandler():GetEquipGroup():IsExists(s.eqfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在可以特殊召唤的「海造贼」怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否发动追加的特殊召唤效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再从卡组把1只「海造贼」怪兽特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从卡组选择1只「海造贼」怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			-- 中断当前效果处理，使后续的特殊召唤处理与加入手卡不视为同时进行。
			Duel.BreakEffect()
			-- 将选择的怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 怪兽效果②的启动与目标检查函数（Target）。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查此卡是否未被禁止放置在灵摆区域，以及自己墓地是否存在可以加入手卡的「海造贼」卡。
	if chk==0 then return not e:GetHandler():IsForbidden() and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己的灵摆区域是否有空位。
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「海造贼」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将作为对象的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 怪兽效果②的效果处理函数（Operation）。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，并将其加入手卡，确认是否成功加入手卡。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		-- 检查自己的灵摆区域是否仍有空位。
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and c:IsRelateToEffect(e) and not c:IsForbidden() then
		-- 将这张卡在自己的灵摆区域表侧表示放置。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
