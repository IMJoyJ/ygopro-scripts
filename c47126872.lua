--スペースタイムポリス
-- 效果：
-- 这张卡特殊召唤成功时，选择对方场上表侧表示存在的1张卡从游戏中除外。这张卡从场上离开时，这张卡的效果从游戏中除外的卡在对方场上盖放。
function c47126872.initial_effect(c)
	-- 这张卡特殊召唤成功时，选择对方场上表侧表示存在的1张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47126872,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c47126872.rmtg)
	e1:SetOperation(c47126872.rmop)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，这张卡的效果从游戏中除外的卡在对方场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47126872,1))  --"盖放"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c47126872.setcon)
	e2:SetTarget(c47126872.settg)
	e2:SetOperation(c47126872.setop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 用于筛选场上正面表示且可以被除外的卡片。
function c47126872.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 选择对方场上正面表示的1张可除外的卡作为效果对象。
function c47126872.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c47126872.filter(chkc) end
	if chk==0 then return true end
	e:SetLabelObject(nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1张正面表示的卡作为目标。
	local g=Duel.SelectTarget(tp,c47126872.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表明将要除外这些卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行除外操作，并记录被除外的卡片。
function c47126872.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标卡片以正面表示形式从游戏中除外，且该卡片不是衍生物，同时自身仍在场上。
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and not tc:IsType(TYPE_TOKEN) and e:GetHandler():IsRelateToEffect(e) then
			e:SetLabelObject(tc)
			tc:RegisterFlagEffect(47126872,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
-- 判断是否曾有卡片被除外，用于触发盖放效果。
function c47126872.setcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	return tc and tc:GetFlagEffect(47126872)~=0
end
-- 设置盖放效果的目标和处理分类。
function c47126872.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject():GetLabelObject()
	-- 设定当前连锁的处理对象为之前被除外的卡片。
	Duel.SetTargetCard(tc)
	if tc:IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		-- 设置效果处理信息，表明将要特殊召唤或盖放该卡。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	else
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 执行盖放操作，根据卡片类型决定是特殊召唤还是盖放。
function c47126872.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
		-- 将目标卡片以里侧守备表示特殊召唤到对方场上。
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	else
		-- 将目标卡片以盖放形式放置到对方场上。
		Duel.SSet(tp,tc,1-tp)
	end
end
