--R.B. Operation Test
-- 效果：
-- 这张卡的发动时：可以以自己墓地1只3星以上的「奏悦机组」怪兽为对象；那只怪兽特殊召唤。
-- 可以以自己场上的「奏悦机组」怪兽任意数量为对象；自己回复那个原本攻击力合计数值的基本分，作为对象的怪兽回到手卡·额外卡组，那之后，可以从手卡把1只「奏悦机组」怪兽特殊召唤。「奏悦机组 运转试验」的这个效果1回合只能使用1次。
-- 「奏悦机组 运转试验」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化效果函数，创建两个效果：一是发动时的效果，二是起动效果。
function s.initial_effect(c)
	-- 这张卡的发动时：可以以自己墓地1只3星以上的「奏悦机组」怪兽为对象；那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	-- 可以以自己场上的「奏悦机组」怪兽任意数量为对象；自己回复那个原本攻击力合计数值的基本分，作为对象的怪兽回到手卡·额外卡组，那之后，可以从手卡把1只「奏悦机组」怪兽特殊召唤。「奏悦机组 运转试验」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回复基本分"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤墓地中的「奏悦机组」怪兽，要求等级3以上、能特殊召唤且场上存在空位。
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(3) and c:IsSetCard(0x1cf)
		-- 检查场上是否有空位，确保能特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为墓地中的符合条件的怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 检查是否场上存在符合条件的怪兽。
	if Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择目标怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要选卡？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.activate)
		-- 提示玩家选择目标怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择目标怪兽。
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置操作信息，将目标怪兽特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 激活效果函数，处理目标怪兽的特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		-- 检查目标怪兽是否受王家长眠之谷影响。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 检查目标怪兽是否受王家长眠之谷保护。
		if not aux.NecroValleyFilter()(tc) then return end
		-- 将目标怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上的「奏悦机组」怪兽，要求正面表示、能回手。
function s.thfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 检查所选怪兽组的攻击力总和是否大于0。
function s.gcheck(g)
	return g:GetSum(Card.GetBaseAttack)>0
end
-- 设置起动效果的目标为场上的「奏悦机组」怪兽。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上的所有「奏悦机组」怪兽。
	local tg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,0,nil,e)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return tg:CheckSubGroup(s.gcheck,1,99) end
	-- 提示玩家选择要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local g=tg:SelectSubGroup(tp,s.gcheck,false,1,99)
	-- 设置操作信息，将怪兽送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	-- 设置当前效果的目标卡组。
	Duel.SetTargetCard(g)
	-- 设置目标卡组的攻击力总和作为参数。
	Duel.SetTargetParam(g:GetSum(Card.GetBaseAttack))
	-- 设置操作信息，回复玩家基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetSum(Card.GetBaseAttack))
end
-- 过滤手卡中的「奏悦机组」怪兽，要求能特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1cf)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理起动效果的后续操作，包括回复基本分、送回手牌、特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡组。
	local g=Duel.GetTargetsRelateToChain()
	-- 检查是否有目标怪兽且成功回复基本分。
	if g:GetCount()>0 and Duel.Recover(tp,g:GetSum(Card.GetBaseAttack),REASON_EFFECT)~=0
		-- 检查目标怪兽是否成功送回手牌。
		and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 获取实际操作的卡组。
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA)
			-- 检查场上是否有空位，确保能特殊召唤。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡中是否存在符合条件的怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 询问玩家是否从手卡特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从手卡特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择要特殊召唤的怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 中断当前效果，使后续效果不同时处理。
				Duel.BreakEffect()
				-- 将选择的怪兽特殊召唤到场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
