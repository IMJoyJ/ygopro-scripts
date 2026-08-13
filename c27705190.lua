--星遺物の交心
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「机怪虫」怪兽存在，对方怪兽的效果发动时才能发动。那个效果变成「选对方场上1只表侧表示怪兽回到持有者手卡」。
-- ②：把墓地的这张卡除外，以场上1只连接怪兽为对象才能发动。从自己的手卡·卡组·墓地选1只「机怪虫」怪兽在作为成为对象的怪兽所连接区的自己场上里侧守备表示特殊召唤。
function c27705190.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上有「机怪虫」怪兽存在，对方怪兽的效果发动时才能发动。那个效果变成「选对方场上1只表侧表示怪兽回到持有者手卡」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27705190,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,27705190)
	e1:SetCondition(c27705190.cecondition)
	e1:SetTarget(c27705190.cetarget)
	e1:SetOperation(c27705190.ceoperation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以场上1只连接怪兽为对象才能发动。从自己的手卡·卡组·墓地选1只「机怪虫」怪兽在作为成为对象的怪兽所连接区的自己场上里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27705190,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27705190)
	-- 设置②效果的发动代价为把墓地的这张卡除外（除外自身作为发动COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27705190.sptarget)
	e2:SetOperation(c27705190.spoperation)
	c:RegisterEffect(e2)
end
-- 定义效果①被替换后的处理函数：选择1只表侧表示且能回手的怪兽，将其返回持有者手卡。
function c27705190.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 由tp从tp视角的对方怪兽区选择1只表侧表示且能加入手卡的怪兽（作为变成后的效果的处理对象）。
	local sg=Duel.SelectMatchingCard(tp,c27705190.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if sg:GetCount()>0 then
		-- 将选择的怪兽以效果原因送回持有者手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 定义「机怪虫」怪兽的判定条件：表侧表示且属于「机怪虫」系列（setcode 0x104）。
function c27705190.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104)
end
-- 定义效果①的发动条件：对方发动怪兽效果，且自己场上有表侧表示的「机怪虫」怪兽存在。
function c27705190.cecondition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果①发动条件：效果发动者是对方（ep≠tp）、被发动效果为怪兽效果、自己场上有表侧「机怪虫」怪兽。
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c27705190.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义可回手牌怪兽的过滤条件：表侧表示且没有「不能加入手卡」限制，可以返回手卡。
function c27705190.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 定义效果①的发动目标检查：确认存在成为变成后效果目标的候选怪兽（表侧表示且能回手）。
function c27705190.cetarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查是否有1只表侧表示且能回手的怪兽存在，以满足效果①发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c27705190.thfilter,rp,0,LOCATION_MZONE,1,nil) end
end
-- 定义效果①发动后的实际处理：清除原连锁的对象，并将原连锁的效果处理函数替换为repop，使该效果变成“选怪兽回手”。
function c27705190.ceoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将当前连锁ev的对象替换为空组，即撤销原效果选择的对象。
	Duel.ChangeTargetCard(ev,g)
	-- 将当前连锁ev的效果处理函数替换为c27705190.repop，以实现“那个效果变成”的效果。
	Duel.ChangeChainOperation(ev,c27705190.repop)
end
-- 定义②效果对象（连接怪兽）的过滤条件：连接怪兽表侧表示，且其连接区域（tp视角）存在可用的主要怪兽区，并有「机怪虫」能特殊召唤到该区域。
function c27705190.spfilter1(c,e,tp)
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 判断连接怪兽是否满足：表侧表示、是连接怪兽、其连接区域有可用空格，并且存在符合条件的「机怪虫」怪兽可以特殊召唤。
	return c:IsFaceup() and c:IsType(TYPE_LINK) and zone>0 and Duel.IsExistingMatchingCard(c27705190.spfilter2,tp,0x13,0,1,c,e,tp,zone)
end
-- 定义可特殊召唤的「机怪虫」怪兽过滤条件：属于「机怪虫」字段，且可以被tp以里侧守备表示特殊召唤到指定区域。
function c27705190.spfilter2(c,e,tp,zone)
	return c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,tp,zone)
end
-- 定义②效果的发动目标选择流程：选择场上1只连接怪兽为对象，并设置操作信息，表示将特殊召唤1只怪兽。
function c27705190.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c27705190.spfilter1(chkc,e,tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动合法性检查：是否存在满足条件的连接怪兽可以作为对象，且其连接区能特殊召唤「机怪虫」。
	if chk==0 then return Duel.IsExistingTarget(c27705190.spfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 向tp玩家弹出选择对象的提示（请选择效果的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 由tp选择场上的1只满足条件的连接怪兽作为效果对象。
	Duel.SelectTarget(tp,c27705190.spfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：本次效果预定从手卡·卡组·墓地（0x13）特殊召唤1只怪兽到tp场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 定义②效果处理：取得对象连接怪兽，若对象仍关联，则在其连接区域选择1只「机怪虫」怪兽里侧守备表示特殊召唤，并向对方展示。
function c27705190.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得作为对象的连接怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local zone=bit.band(tc:GetLinkedZone(tp),0x1f)
		-- 向tp玩家弹出选择特殊召唤怪兽的提示（请选择要特殊召唤的卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·卡组·墓地（0x13）选择1只满足spfilter2且不受王家长眠之谷影响的「机怪虫」怪兽。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27705190.spfilter2),tp,0x13,0,1,1,c,e,tp,zone)
		if sg:GetCount()>0 then
			-- 将选择的「机怪虫」怪兽以里侧守备表示特殊召唤到对象连接怪兽所连接区的自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE,zone)
			-- 向对方玩家展示特殊召唤的怪兽，确认其信息。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
