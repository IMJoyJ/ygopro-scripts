--吹き荒れるウィン
-- 效果：
-- 可以把自己场上除这张卡以外的1只风属性怪兽做祭品，从手卡特殊召唤1只风属性怪兽。这个效果1回合只能使用1次。这个效果特殊召唤的怪兽，在「猛吹之薇茵」从自己场上离开的场合破坏。
function c29013526.initial_effect(c)
	-- 可以把自己场上除这张卡以外的1只风属性怪兽做祭品，从手卡特殊召唤1只风属性怪兽。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c29013526.spcost)
	e1:SetTarget(c29013526.sptg)
	e1:SetOperation(c29013526.spop)
	c:RegisterEffect(e1)
end
-- 作为发动代价，从自己场上选择并解放这张卡以外的1只风属性怪兽。
function c29013526.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查自己场上是否存在至少1只除这张卡以外的风属性怪兽，可作为祭品解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_WIND) end
	-- 让玩家从自己场上选择1只除这张卡以外的风属性怪兽作为祭品。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_WIND)
	-- 解放所选择的怪兽，作为效果发动的代价（cost）。
	Duel.Release(g,REASON_COST)
end
-- 定义可作为特殊召唤对象的怪兽条件：手牌中的风属性怪兽，且能够被当前效果特殊召唤。
function c29013526.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标选择：确认自己场上有可用怪兽区空格，且手牌中存在符合条件的风属性怪兽，才能发动。
function c29013526.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足filter条件的风属性怪兽。
		and Duel.IsExistingMatchingCard(c29013526.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：从手卡特殊召唤1只风属性怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若场上还有空格，则从手牌选择1只风属性怪兽特殊召唤，并为该怪兽附加‘猛吹之薇茵离场时破坏’的持续效果。
function c29013526.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用怪兽区空格，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选出符合条件的1只风属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c29013526.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽，在「猛吹之薇茵」从自己场上离开的场合破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c29013526.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- 持续效果的触发处理：当「猛吹之薇茵」离场时，破坏持有这个效果的怪兽。
function c29013526.desop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsCode,1,nil,29013526) then
		-- 将承载此效果的那只特殊召唤的怪兽破坏，破坏原因为效果。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
