--暗躍のドルイド・ウィド
-- 效果：
-- 这张卡从场上送去墓地的场合，可以选择自己墓地1张永续魔法卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。「暗跃的德鲁伊·智者」的效果1回合只能使用1次。
function c97064649.initial_effect(c)
	-- 这张卡从场上送去墓地的场合，可以选择自己墓地1张永续魔法卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。「暗跃的德鲁伊·智者」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97064649,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,97064649)
	e1:SetCondition(c97064649.setcon)
	e1:SetTarget(c97064649.settg)
	e1:SetOperation(c97064649.setop)
	c:RegisterEffect(e1)
end
-- 检查此卡是否是从场上送去墓地
function c97064649.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己墓地中可以盖放的永续魔法卡
function c97064649.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 效果发动的对象选择与合法性检测
function c97064649.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c97064649.filter(chkc) end
	-- 检查自己魔陷区是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在满足条件的永续魔法卡
		and Duel.IsExistingTarget(c97064649.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张永续魔法卡作为效果的对象
	Duel.SelectTarget(tp,c97064649.filter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 效果处理：将选择的永续魔法卡在自己场上盖放，并限制其在本回合不能发动
function c97064649.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍与效果相关，则将其在自己场上盖放
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在这个回合不能发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
