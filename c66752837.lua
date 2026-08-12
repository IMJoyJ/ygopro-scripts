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
	-- ②：这张卡在手卡·墓地存在，「灵庙守护者」以外的场上的表侧表示的龙族怪兽被效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。这张卡特殊召唤。送去墓地的怪兽是通常怪兽的场合，可以再选自己墓地1只龙族通常怪兽加入手卡。
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
-- 判断解放召唤的怪兽是否为龙族怪兽
function c66752837.tricon(e,c)
	return c:IsRace(RACE_DRAGON)
end
-- 过滤满足「灵庙守护者」以外的场上表侧表示的龙族怪兽因效果或战斗送去墓地条件的卡片
function c66752837.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:GetPreviousRaceOnField()==RACE_DRAGON
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsCode(66752837)
end
-- 判断发动条件：自身不在送墓卡片中，且有其他符合条件的龙族怪兽送墓，若其中有通常怪兽则将效果标签设为1
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
-- 效果发动的目标检测：检查怪兽区域是否有空位，以及自身是否可以特殊召唤
function c66752837.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤自己墓地中可以加入手牌的龙族通常怪兽
function c66752837.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 效果处理：将自身特殊召唤，若送去墓地的是通常怪兽，则可以再选择自己墓地1只龙族通常怪兽加入手牌
function c66752837.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取自己墓地中满足条件且不受王家长眠之谷影响的龙族通常怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c66752837.thfilter),tp,LOCATION_GRAVE,0,nil)
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤，若特殊召唤成功且之前判定送去墓地的怪兽是通常怪兽
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and e:GetLabel()==1
		-- 若墓地存在符合条件的卡，则询问玩家是否选择将1只龙族通常怪兽加入手牌
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(66752837,0)) then  --"是否选墓地1只龙族通常怪兽加入手卡？"
		-- 中断当前效果处理，使后续的加入手牌处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 给玩家发送提示信息：请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片因效果加入持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
