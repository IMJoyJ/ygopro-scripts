--伝説の騎士 クリティウス
-- 效果：
-- 这张卡不能通常召唤。「传说之心」的效果才能特殊召唤。
-- ①：这张卡特殊召唤成功时，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的魔法·陷阱卡除外。
-- ②：这张卡被选择作为攻击对象时，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c85800949.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「传说之心」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的魔法·陷阱卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85800949,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(c85800949.rmtg)
	e2:SetOperation(c85800949.rmop)
	c:RegisterEffect(e2)
	-- ②：这张卡被选择作为攻击对象时，以自己墓地1张陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetDescription(aux.Stringid(85800949,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c85800949.settg)
	e3:SetOperation(c85800949.setop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且可以被除外的魔法·陷阱卡
function c85800949.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove() and c:IsFaceup()
end
-- 效果①（除外场上表侧表示魔陷）的发动准备（Target）
function c85800949.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c85800949.rmfilter(chkc) end
	-- 检查场上是否存在可以作为除外对象的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c85800949.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张表侧表示的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c85800949.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为：除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①（除外场上表侧表示魔陷）的效果处理（Operation）
function c85800949.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		-- 将目标卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤自己墓地可以盖放的陷阱卡
function c85800949.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果②（墓地陷阱盖放）的发动准备（Target）
function c85800949.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c85800949.setfilter(chkc) end
	-- 检查自己墓地是否存在可以作为盖放对象的陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c85800949.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c85800949.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：使目标卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②（墓地陷阱盖放）的效果处理（Operation）
function c85800949.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若目标卡片仍对应此效果，则将其在自己场上盖放，若成功盖放则执行后续处理
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(85800949,2))  --"适用「传说的骑士 克里底亚」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
