--方界超獣バスター・ガンダイル
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升3000。
-- ②：这张卡在同1次的战斗阶段中可以作3次攻击。
-- ③：这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
function c4998619.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只「方界」怪兽送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c4998619.spcon)
	e2:SetTarget(c4998619.sptg)
	e2:SetOperation(c4998619.spop)
	c:RegisterEffect(e2)
	-- 这张卡在同1次的战斗阶段中可以作3次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(2)
	c:RegisterEffect(e3)
	-- 这张卡被对方送去墓地的场合，以自己墓地最多3只「方界」怪兽为对象才能发动。那些怪兽特殊召唤。那之后，可以从自己的卡组·墓地选1张「方界」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c4998619.spcon2)
	e4:SetTarget(c4998619.sptg2)
	e4:SetOperation(c4998619.spop2)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的场上「方界」怪兽（表侧表示、属于「方界」、可以送去墓地作为费用）
function c4998619.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost()
end
-- 检查玩家场上是否有3只满足条件的「方界」怪兽
function c4998619.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上满足条件的「方界」怪兽组
	local mg=Duel.GetMatchingGroup(c4998619.filter,tp,LOCATION_MZONE,0,nil)
	-- 检查该组是否能选出3只满足条件的怪兽
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 选择3只满足条件的怪兽并将其送去墓地作为特殊召唤的费用
function c4998619.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上满足条件的「方界」怪兽组
	local mg=Duel.GetMatchingGroup(c4998619.filter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从满足条件的怪兽中选择3只组成组
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选择的怪兽组送去墓地作为费用，并给这张卡增加3000攻击力
function c4998619.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将怪兽组送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
	-- 这个方法特殊召唤的这张卡的攻击力上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(3000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 判断是否为对方将此卡送入墓地
function c4998619.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤满足条件的「方界」怪兽（属于「方界」、可以特殊召唤）
function c4998619.spfilter(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的目标选择条件
function c4998619.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4998619.spfilter(chkc,e,tp) end
	-- 检查玩家是否有足够的怪兽区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的「方界」怪兽
		and Duel.IsExistingTarget(c4998619.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=3
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 限制可特殊召唤的数量为怪兽区空位数与3中的较小值
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽进行特殊召唤
	local g=Duel.SelectTarget(tp,c4998619.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 过滤满足条件的「方界」卡（属于「方界」、可以加入手牌）
function c4998619.thfilter(c)
	return c:IsSetCard(0xe3) and c:IsAbleToHand()
end
-- 处理效果发动后的操作：特殊召唤目标怪兽并检索卡组
function c4998619.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前可用的怪兽区空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中指定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取满足条件的「方界」卡组（包括卡组和墓地）
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c4998619.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		-- 询问是否将一张「方界」卡加入手牌
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(4998619,0)) then  --"是否把1张「方界」卡加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			sg=sg:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
		end
	end
end
