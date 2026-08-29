--霊廟の守護者
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：龙族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ②：这张卡在手卡·墓地存在，「灵庙守护者」以外的场上的表侧表示的龙族怪兽被效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。这张卡特殊召唤。送去墓地的怪兽是通常怪兽的场合，可以再选自己墓地1只龙族通常怪兽加入手卡。
function c66752837.initial_effect(c)
	-- ①：龙族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c66752837.tricon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在手卡·墓地存在，「灵庙守护者」以外的场上的表侧表示的龙族怪兽被效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。这张卡特殊召唤。送去墓地的怪兽是通常怪兽的场合，可以再选自己墓地1只龙族通常怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,66752837)
	e2:SetCondition(c66752837.spcon)
	e2:SetTarget(c66752837.sptg)
	e2:SetOperation(c66752837.spop)
	c:RegisterEffect(e2)
end
-- 判断是否作为龙族怪兽上级召唤的2只解放（自身表侧表示或为同一控制者）
function c66752837.tricon(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_DRAGON) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 过滤场上表侧表示因效果或战斗破坏送去墓地的「灵庙守护者」以外的龙族怪兽
function c66752837.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:GetPreviousRaceOnField()==RACE_DRAGON
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsCode(66752837)
end
-- 特殊召唤效果的发动条件判定（记录送去墓地的怪兽是否包含通常怪兽）
function c66752837.spcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	local g=eg:Filter(c66752837.cfilter,nil)
	if g:GetCount()==0 then return false end
	e:SetLabel(0)
	if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		e:SetLabel(1)
	end
	return true
end
-- 特殊召唤自身效果的目标确认
function c66752837.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤墓地中可以加入手卡的龙族通常怪兽
function c66752837.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 执行特殊召唤自身以及从墓地回收龙族通常怪兽的效果处理
function c66752837.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区是否有空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取墓地中可以加入手卡的龙族通常怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c66752837.thfilter),tp,LOCATION_GRAVE,0,nil)
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤上场，并判断送去墓地的怪兽是否包含通常怪兽
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and e:GetLabel()==1
		-- 询问玩家是否将墓地1只龙族通常怪兽加入手卡
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(66752837,0)) then  --"是否选墓地1只龙族通常怪兽加入手卡？"
		-- 中断效果处理，使之后的加入手卡视为不同时处理
		Duel.BreakEffect()
		-- 设置选择加入手卡卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的龙族通常怪兽加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家出示确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
