--ブロック・ゴーレム
-- 效果：
-- ①：自己墓地的怪兽只有地属性的场合，把这张卡解放，以「积木巨人」以外的自己墓地2只4星以下的岩石族怪兽为对象才能发动。那些岩石族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把场上发动的效果发动。
function c72580321.initial_effect(c)
	-- ①：自己墓地的怪兽只有地属性的场合，把这张卡解放，以「积木巨人」以外的自己墓地2只4星以下的岩石族怪兽为对象才能发动。那些岩石族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72580321,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c72580321.spcon)
	e1:SetCost(c72580321.spcost)
	e1:SetTarget(c72580321.sptg)
	e1:SetOperation(c72580321.spop)
	c:RegisterEffect(e1)
end
-- 过滤非地属性怪兽的条件函数
function c72580321.cfilter(c)
	return c:GetAttribute()~=ATTRIBUTE_EARTH
end
-- 效果发动条件：自己墓地存在怪兽，且所有怪兽都是地属性
function c72580321.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地的所有怪兽卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>0 and not g:IsExists(c72580321.cfilter,1,nil)
end
-- 效果发动代价：解放自身
function c72580321.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中「积木巨人」以外的4星以下岩石族且可以特殊召唤的怪兽
function c72580321.filter(c,e,tp)
	return c:IsLevelBelow(4) and not c:IsCode(72580321) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检测
function c72580321.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72580321.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有至少1个空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在2只满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c72580321.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c72580321.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤2只目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理：将选择的2只怪兽特殊召唤，并适用在这个回合不能把场上发动的效果发动的限制
function c72580321.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local tc=g:GetFirst()
	while tc do
		-- 尝试将目标怪兽以表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽在这个回合不能把场上发动的效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
