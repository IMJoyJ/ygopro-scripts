--ハーピィ・オラクル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：自己场上有5星以上的「鹰身」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ③：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从自己墓地选有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。
function c66386380.initial_effect(c)
	-- 注册该卡的效果文本中记载了卡名「鹰身女郎三姐妹」（卡号12206212），以便其他卡片或系统进行检测。
	aux.AddCodeList(c,12206212)
	-- ③：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从自己墓地选有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66386380,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,66386380)
	e1:SetOperation(c66386380.regop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 使这张卡在场上·墓地存在时，卡名当作「鹰身女郎」使用。
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：自己场上有5星以上的「鹰身」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(66386380,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,66386381)
	e4:SetCondition(c66386380.sscon)
	e4:SetTarget(c66386380.sstg)
	e4:SetOperation(c66386380.ssop)
	c:RegisterEffect(e4)
end
-- 召唤·特殊召唤成功效果的执行函数：在全局注册一个在当前回合结束阶段触发的延迟效果。
function c66386380.regop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：自己场上有5星以上的「鹰身」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。③：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从自己墓地选有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c66386380.thcon)
	e1:SetOperation(c66386380.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该回合结束阶段触发的延迟效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：检索自己墓地中记载了「鹰身女郎三姐妹」卡名的魔法·陷阱卡，且该卡能加入手牌。
function c66386380.thfilter(c)
	-- 检查卡片是否记载了「鹰身女郎三姐妹」卡名、是否为魔法·陷阱卡，以及是否能加入手牌。
	return aux.IsCodeListed(c,12206212) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 结束阶段效果的发动条件：自己墓地存在至少1张满足条件的魔法·陷阱卡。
function c66386380.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张满足条件的魔法·陷阱卡。
	return Duel.IsExistingMatchingCard(c66386380.thfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 结束阶段效果的执行：从自己墓地选择1张满足条件的卡加入手牌。
function c66386380.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件且不受「王家长眠之谷」影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66386380.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片因效果加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤函数：检索自己场上表侧表示的5星以上的「鹰身」怪兽。
function c66386380.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsLevelAbove(5)
end
-- 特殊召唤效果的发动条件：自己场上存在5星以上的「鹰身」怪兽。
function c66386380.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的5星以上的「鹰身」怪兽。
	return Duel.IsExistingMatchingCard(c66386380.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的靶向/发动检测：检查怪兽区域是否有空位，以及自身是否能特殊召唤。
function c66386380.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：若自身仍存在于手牌中，则将其表侧表示特殊召唤到自己场上。
function c66386380.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
