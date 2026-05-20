--モンスターエクスプレス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。原本种族和那只表侧表示怪兽相同的1只怪兽从额外卡组送去墓地。这个回合，自己若非这个效果送去墓地的怪兽以及原本种族和那只怪兽相同的怪兽则不能特殊召唤。
function c637216.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。原本种族和那只表侧表示怪兽相同的1只怪兽从额外卡组送去墓地。这个回合，自己若非这个效果送去墓地的怪兽以及原本种族和那只怪兽相同的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(637216,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,637216)
	e1:SetTarget(c637216.tgtg)
	e1:SetOperation(c637216.tgop)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤条件：自己场上表侧表示的怪兽，且额外卡组存在原本种族与之相同的可送去墓地的怪兽
function c637216.cfilter(c,tp)
	-- 过滤条件：卡片表侧表示，且额外卡组存在至少1张原本种族相同且能送去墓地的卡
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c637216.tgfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetOriginalRace())
end
-- 定义额外卡组送墓怪兽的过滤条件：可以送去墓地，且原本种族与指定种族相同
function c637216.tgfilter(c,race)
	return c:IsAbleToGrave() and c:GetOriginalRace()==race
end
-- 定义效果的发动准备（Target）
function c637216.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c637216.cfilter(chkc,tp) end
	-- 在发动阶段，检查自己场上是否存在符合条件的可选择为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c637216.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c637216.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：从额外卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果的效果处理（Operation）
function c637216.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local race=tc:GetOriginalRace()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从额外卡组选择1只原本种族与对象怪兽相同的怪兽
		local g=Duel.SelectMatchingCard(tp,c637216.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,race)
		-- 若成功将选择的怪兽送去墓地
		if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			-- 这个回合，自己若非这个效果送去墓地的怪兽以及原本种族和那只怪兽相同的怪兽则不能特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetLabel(g:GetFirst():GetOriginalRace())
			e1:SetTargetRange(1,0)
			e1:SetTarget(c637216.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 给玩家注册不能特殊召唤特定种族以外怪兽的限制效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 限制不能特殊召唤与送墓怪兽原本种族不同的怪兽
function c637216.splimit(e,c)
	return not c:IsRace(e:GetLabel())
end
