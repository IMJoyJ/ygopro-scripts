--海皇龍 ポセイドラ
-- 效果：
-- 把自己场上3只3星以下的水属性怪兽解放才能发动。这张卡从手卡或者墓地特殊召唤。这个效果特殊召唤成功时，场上的魔法·陷阱卡全部回到持有者手卡。这个效果让卡3张以上回到手卡的场合，对方场上的全部怪兽的攻击力下降回到手卡的卡数量×300的数值。
function c47826112.initial_effect(c)
	-- 把自分场上3只3星以下的水属性怪兽解放才能发动。这张卡从手卡或者墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47826112,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(c47826112.spcost)
	e1:SetTarget(c47826112.sptg)
	e1:SetOperation(c47826112.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，场上的魔法·陷阱卡全部回到持有者手卡。这个效果让卡3张以上回到手卡的场合，对方场上的全部怪兽的攻击力下降回到手卡的卡数量×300的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47826112,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c47826112.thcon)
	e2:SetTarget(c47826112.thtg)
	e2:SetOperation(c47826112.thop)
	c:RegisterEffect(e2)
end
-- 用于筛选满足条件的怪兽：等级不超过3星且为水属性，并且是自己控制或正面表示的怪兽。
function c47826112.cfilter(c,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否有满足条件的3只怪兽可以解放，若没有则无法发动此效果；提示玩家选择要解放的3只怪兽并实际执行解放操作。
function c47826112.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽组，并筛选出符合条件的水属性怪兽。
	local rg=Duel.GetReleaseGroup(tp):Filter(c47826112.cfilter,nil,tp)
	-- 在不执行实际操作的情况下检查是否能选出3只满足条件的怪兽进行解放。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,3,3,tp) end
	-- 向玩家发送提示信息，要求选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从符合条件的怪兽中选择恰好3只，并验证其是否可以被正常释放。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,3,3,tp)
	-- 使用额外的解放次数（如暗影敌托邦的效果）来处理本次特殊召唤所需的解放。
	aux.UseExtraReleaseCount(g,tp)
	-- 正式将所选怪兽进行解放操作，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 设置特殊召唤的目标和条件，确保该卡可以被正常特殊召唤。
function c47826112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中要处理的特殊召唤信息，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将该卡以自身效果从手牌或墓地特殊召唤到场上。
function c47826112.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以自身效果特殊召唤到场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 判断该卡是否是通过特殊召唤方式（非通常召唤）成功召唤的。
function c47826112.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 用于筛选场上的魔法·陷阱卡，确保这些卡可以被送回手牌。
function c47826112.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置返回手牌的效果目标和信息，准备执行将魔法·陷阱卡送回手牌的操作。
function c47826112.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有满足条件的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c47826112.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁中要处理的返回手牌信息，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行将魔法·陷阱卡送回手牌的操作，并根据送回数量判断是否触发攻击力下降效果。
function c47826112.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c47826112.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这些魔法·陷阱卡全部送回持有者手牌。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	if ct>=3 then
		-- 获取对方场上的正面表示怪兽组。
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=mg:GetFirst()
		while tc do
			-- 为对方场上的每个正面表示怪兽添加攻击力下降效果，数值等于送回手牌的卡数量乘以300。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-ct*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=mg:GetNext()
		end
	end
end
