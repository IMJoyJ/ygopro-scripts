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
-- 初始化卡片效果：赋予灵摆与同调召唤属性，并注册灵摆效果（回额外特召双方衍生物）以及怪兽①效果（对方特召检索「海造贼」卡并有装备时可追召）和②效果（回收墓地「海造贼」卡并自身放回灵摆区）
function s.initial_effect(c)
	-- 赋予灵摆怪兽属性，且不注册灵摆区常规“卡的发动”效果
	aux.EnablePendulumAttribute(c,false)
	-- 设置同调召唤条件：需要调整1只＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ←1 【灵摆】 1→ 这个卡名的灵摆效果1回合只能使用1次。 ①：宣言1个属性才能发动。这张卡回到持有者的额外卡组，把持有宣言的属性的「海造贼衍生物」（恶魔族·4星·攻/守0）在双方场上各1只守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】 调整＋调整以外的怪兽1只以上 这个卡名的①②的怪兽效果1回合各能使用1次。 ①：对方对怪兽的特殊召唤成功的场合才能发动。从卡组把1张「海造贼」卡加入手卡。这张卡有「海造贼」卡装备的场合，可以再从卡组把1只「海造贼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组把1张「海造贼」卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：以自己墓地1张「海造贼」卡为对象才能发动。那张卡加入手卡，这张卡在自己的灵摆区域放置。
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
-- 辅助函数：遍历所有属性，返回能让双方各自合法表侧守备特殊召唤1只对应属性「海造贼衍生物」的合法属性掩码
function s.GetLegalAttributesOnly(tp)
	local a,attr=1,0
	while a<ATTRIBUTE_ALL do
		local check=true
		for p=0,1 do
			-- 检查己方能否将恶魔族·4星·攻/守0·指定属性的「海造贼衍生物」以表侧守备表示特殊召唤到玩家p场上
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
-- 灵摆效果的发动检测：确认自身能回额外卡组、双方怪兽区均有空位、未受青眼精灵龙限制且存在可宣言的合法属性
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查这张卡是否可表侧加入额外卡组，且这张卡离场后己方怪兽区是否有空位
		if not c:IsAbleToExtra() or Duel.GetMZoneCount(tp,c)<=0
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			or Duel.GetMZoneCount(1-tp,c,tp)<=0 or Duel.IsPlayerAffectedByEffect(tp,59822133) then
			return false
		end
		return s.GetLegalAttributesOnly(tp)~=0
	end
	-- 向己方提示选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让己方从所有合法属性中宣言1个属性
	local attr=Duel.AnnounceAttribute(tp,1,s.GetLegalAttributesOnly(tp))
	-- 将当前连锁的目标参数设置为所宣言的属性
	Duel.SetTargetParam(attr)
	-- 登记连锁的回额外卡组操作信息，预计将灵摆区的这张卡回到额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 登记连锁的衍生物生成操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记连锁的特殊召唤操作信息，预计在双方场上特殊召唤合计2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,0)
end
-- 灵摆效果的处理前半部分：将自身表侧回到额外卡组，读取宣言属性并再次校验双方场上特召条件与空位及青眼精灵龙限制
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将这张卡以效果回到持有者额外卡组并确认其成功进入额外卡组，否则终止处理
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_EXTRA) then return end
	-- 从当前连锁信息中取出发动时宣言的属性
	local attr=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if not attr or attr==0
		-- 检查当前是否仍能将所宣言属性的「海造贼衍生物」特殊召唤到己方场上
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x13f,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,attr,POS_FACEUP_DEFENSE,tp)
		-- 检查当前是否仍能将所宣言属性的「海造贼衍生物」特殊召唤到对方场上
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x13f,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,attr,POS_FACEUP_DEFENSE,1-tp)
		-- 检查双方主要怪兽区是否都仍有可用空位
		or Duel.GetMZoneCount(tp,c)<=0 or Duel.GetMZoneCount(1-tp,c,tp)<=0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then
		return
	end
	-- 按当前回合玩家优先的顺序遍历双方玩家
	for p in aux.TurnPlayers() do
		-- 创建1只「海造贼衍生物」卡片对象
		local token=Duel.CreateToken(tp,id+o)
		-- 把持有宣言的属性的「海造贼衍生物」（恶魔族·4星·攻/守0）在双方场上各1只守备表示特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(attr)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1,true)
		-- 执行分步特殊召唤，将变更属性后的「海造贼衍生物」以表侧守备表示特殊召唤到玩家p场上
		Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成分步特殊召唤，使双方场上的衍生物同时登场
	Duel.SpecialSummonComplete()
end
-- 怪兽①效果的发动条件检查：确认本次特殊召唤成功的怪兽中存在由对方玩家特殊召唤的怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 筛选条件：检查卡片是否为可加入手卡的「海造贼」卡
function s.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsAbleToHand()
end
-- 怪兽①效果的发动检测与连锁信息设置：确认己方卡组存在可加入手卡的「海造贼」卡，并登记加入手卡操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方卡组存在至少1张可加入手卡的「海造贼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记连锁的加入手卡操作信息，预计从己方卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 筛选条件：检查卡片是否为可特殊召唤的「海造贼」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x13f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选条件：检查装备卡是否为表侧表示的「海造贼」卡
function s.eqfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 怪兽①效果的处理流程：从卡组选1张「海造贼」卡加入手卡并展示；若这张卡装备有「海造贼」卡且有空位，则可选再从卡组特召1只「海造贼」怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方提示选择要加入手卡的「海造贼」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从己方卡组选择1张「海造贼」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 以效果将所选卡加入手卡，并确认其成功进入手卡
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方展示加入手卡的「海造贼」卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查这张卡是否装备有「海造贼」卡且己方主要怪兽区存在可用空位
		if e:GetHandler():GetEquipGroup():IsExists(s.eqfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查己方卡组中是否存在可特殊召唤的「海造贼」怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问己方是否再从卡组把1只「海造贼」怪兽特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再从卡组把1只「海造贼」怪兽特殊召唤？"
			-- 向己方提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让己方从己方卡组选择1只「海造贼」怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			-- 中断效果处理，使后续的特殊召唤与前面的加入手卡视为不同时处理
			Duel.BreakEffect()
			-- 将所选「海造贼」怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 怪兽②效果的发动检测：确认自身未被禁止放置、墓地有可回手卡的「海造贼」卡且己方灵摆区存在空位
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动条件检查（前半）：确认这张卡未被禁止在场上存在，且己方墓地存在可加入手卡的「海造贼」卡
	if chk==0 then return not e:GetHandler():IsForbidden() and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 发动条件检查（后半）：确认己方左右灵摆区域中至少有1处空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	-- 向己方提示选择要加入手卡的墓地「海造贼」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从己方墓地选择1张「海造贼」卡作为连锁对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记连锁的加入手卡操作信息，预计将所选墓地卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 怪兽②效果的处理流程：将对象卡加入手卡并确认进入手卡后，若灵摆区有空位且这张卡仍在连锁中且未被禁止，则将其放置到己方灵摆区
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁所指定的己方墓地「海造贼」卡对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在连锁中并以效果将其加入手卡，且确认成功进入手卡
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		-- 检查此时己方灵摆区域是否仍有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and c:IsRelateToEffect(e) and not c:IsForbidden() then
		-- 将这张卡以表侧表示放置到己方灵摆区域并使灵摆效果即时适用
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
