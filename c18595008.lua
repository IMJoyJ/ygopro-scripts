--捕食植物テッポウリザード
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「捕食植物」怪兽或「凶饿毒」怪兽存在的场合才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「融合」加入手卡。
-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的属性直到回合结束时变成暗属性。
-- ③：这张卡从墓地特殊召唤的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化该卡的效果：注册①手牌存在且场上有「捕食植物」或「凶饿毒」怪兽时特殊召唤并检索「融合」；②取对象将1只表侧表示怪兽变暗属性；③从墓地特殊召唤成功时抽1；三个效果各1回合1次。
function s.initial_effect(c)
	-- 登记此卡记载的卡名「融合」（24094653），用于相关规则判定。
	aux.AddCodeList(c,24094653)
	-- ①：这张卡在手卡存在，自己场上有「捕食植物」怪兽或「凶饿毒」怪兽存在的场合才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的属性直到回合结束时变成暗属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变属性"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	-- ③：这张卡从墓地特殊召唤的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 定义过滤条件：怪兽为表侧表示且属于「捕食植物」或「凶饿毒」系列（用于①的发动条件）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f3,0x1050)
end
-- ①效果的发动条件：此卡在手牌存在，且自己场上有表侧表示的「捕食植物」或「凶饿毒」怪兽时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足s.cfilter条件的表侧表示「捕食植物」或「凶饿毒」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动时的目标判定：确认此卡可以被特殊召唤，且自己场上怪兽区域有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位（用于特殊召唤此卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本效果将进行1次特殊召唤（对象为此卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义检索过滤条件：卡组中的「融合」（24094653），且该卡能够被加入手卡。
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ①效果处理：将此卡特殊召唤；若特召成功且卡组有「融合」，询问玩家后从卡组选择1张「融合」加入手卡，并向对方展示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡仍与当前连锁关联，并尝试将其表侧表示特殊召唤；特召成功时才继续执行检索。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 确认卡组中存在可以加入手卡的「融合」卡片。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否要将「融合」加入手卡，选择是才执行检索。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否加入手卡？"
		-- 发送选择提示，提示玩家接下来选择要加入手卡的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足s.thfilter的「融合」卡片。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续加入手卡处理与特殊召唤视为不同时处理（对应“那之后”的时点）。
			Duel.BreakEffect()
			-- 将选择的「融合」以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的「融合」，让对方确认检索结果。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义②的对象过滤条件：表侧表示且不是暗属性的怪兽（因为需要将其变更为暗属性）。
function s.attfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②效果发动目标处理：以场上1只表侧表示且非暗属性的怪兽为对象；选择对象时验证对象合法，并让玩家选择。
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.attfilter(chkc) end
	-- 检查场上是否存在至少1只表侧表示且非暗属性的怪兽能够成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只表侧表示且非暗属性的怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,s.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：将对象怪兽的属性变更为暗属性，持续到回合结束。
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and not tc:IsAttribute(ATTRIBUTE_DARK) then
		-- 那只怪兽的属性直到回合结束时变成暗属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：此卡从墓地特殊召唤成功（特殊召唤前所在位置为墓地）。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- ③效果发动目标：确认自己可以抽1张卡，并设置抽卡玩家为自己、抽卡数量为1及操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够通过效果抽1张卡（受“不能抽卡”效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息，声明本效果处理将进行1次抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③效果处理：从连锁信息中取得抽卡玩家和抽卡数量，执行抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家（p）和对象参数（d），即抽卡玩家与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
