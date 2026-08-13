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
-- 筛选对方场上表侧表示且能够被除外的卡。
function c47126872.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 第一个效果的发动条件与取对象处理：确认可以发动后，选择对方场上表侧表示且可除外的1张卡作为对象，并设置除外相关的操作信息。
function c47126872.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c47126872.filter(chkc) end
	if chk==0 then return true end
	e:SetLabelObject(nil)
	-- 显示选择提示，要求当前玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1张表侧表示且可除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c47126872.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息，标明将除外选择的卡，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 第一个效果处理：将对象卡以表侧表示除外；若除外成功且对象不是衍生物、时空警察仍与效果关联，则记录该卡并为其注册标记，用于之后离场时将其盖放。
function c47126872.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第一个效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外；若除外成功且该卡不是衍生物、时空警察仍与效果关联，则继续执行记录操作。
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and not tc:IsType(TYPE_TOKEN) and e:GetHandler():IsRelateToEffect(e) then
			e:SetLabelObject(tc)
			tc:RegisterFlagEffect(47126872,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
-- 第二效果的发动条件：被第一效果除外的卡依然存在且带有标记（未被重置）。
function c47126872.setcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	return tc and tc:GetFlagEffect(47126872)~=0
end
-- 第二效果发动时：取出被第一效果除外的卡，将其设为连锁对象；若该卡是怪兽则将效果分类设为特殊召唤+里侧守备盖放怪兽，否则设为盖放魔陷。
function c47126872.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject():GetLabelObject()
	-- 将被除外的卡登记为当前连锁的处理对象，便于效果处理时获取。
	Duel.SetTargetCard(tc)
	if tc:IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		-- 设置操作信息：将那张怪兽特殊召唤到对方场上。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	else
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 第二效果处理：若对象仍与效果关联，则怪兽以里侧守备表示特殊召唤到对方场上，魔法陷阱卡以里侧表示盖放到对方场上。
function c47126872.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第二效果连锁中登记的对象卡（即被第一效果除外的卡）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
		-- 将那张怪兽以里侧守备表示特殊召唤到对方场上。
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	else
		-- 将那张卡以里侧表示盖放到对方场上（魔法陷阱区）。
		Duel.SSet(tp,tc,1-tp)
	end
end
