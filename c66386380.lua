--ハーピィ・オラクル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：自己场上有5星以上的「鹰身」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ③：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从自己墓地选有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。
function c66386380.initial_effect(c)
	-- 记录这张卡的效果文本上记述有「鹰身女郎三姐妹」的卡名
	aux.AddCodeList(c,12206212)
	-- 这个卡名的②③的效果1回合各能使用1次。③：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从自己墓地选有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66386380,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,66386380)
	e1:SetOperation(c66386380.regop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 实现①效果：使这张卡的卡名只要在场上·墓地存在就当作「鹰身女郎」使用
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
-- ③效果发动处理：注册在本回合结束阶段执行的墓地回收持续效果
function c66386380.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从自己墓地选有「鹰身女郎三姐妹」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c66386380.thcon)
	e1:SetOperation(c66386380.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为发动玩家注册结束阶段执行的全局持续效果
	Duel.RegisterEffect(e1,tp)
end
-- ③效果回收过滤函数：筛选记述有「鹰身女郎三姐妹」卡名且可加入手卡的魔法·陷阱卡
function c66386380.thfilter(c)
	-- 检查卡片效果文本记述了「鹰身女郎三姐妹」、属于魔法或陷阱卡且可以加入手卡
	return aux.IsCodeListed(c,12206212) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 结束阶段回收触发条件：检查自己墓地是否存在符合条件的魔法·陷阱卡
function c66386380.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张满足回收条件的魔法·陷阱卡
	return Duel.IsExistingMatchingCard(c66386380.thfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 结束阶段回收处理：从自己墓地选择1张符合条件的魔法·陷阱卡加入手卡并向对方展示
function c66386380.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择墓地中要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张不受王家长眠之谷影响且记述「鹰身女郎三姐妹」的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66386380.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 以效果原因将选中的魔法·陷阱卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②效果条件过滤函数：筛选场上表侧表示的5星以上「鹰身」怪兽
function c66386380.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsLevelAbove(5)
end
-- ②效果发动条件：检查自己场上是否存在5星以上的表侧「鹰身」怪兽
function c66386380.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只5星以上的表侧「鹰身」怪兽
	return Duel.IsExistingMatchingCard(c66386380.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果目标设定：检查自己怪兽区空位及自身是否可特召，并登记特殊召唤操作信息
function c66386380.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 声明本次效果会将手卡中的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果有联系，则从手卡表侧表示特殊召唤
function c66386380.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从手卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
