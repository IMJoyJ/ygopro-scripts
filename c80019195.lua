--伝説の騎士 ティマイオス
-- 效果：
-- 这张卡不能通常召唤。「传说之心」的效果才能特殊召唤。
-- ①：这张卡特殊召唤成功时，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的魔法·陷阱卡除外。
-- ②：这张卡被选择作为攻击对象时，以自己墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
function c80019195.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「传说之心」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为恒常不满足（即不能通过常规方式特殊召唤，只能通过特定卡的效果特殊召唤）。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的魔法·陷阱卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80019195,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c80019195.rmtg)
	e2:SetOperation(c80019195.rmop)
	c:RegisterEffect(e2)
	-- ②：这张卡被选择作为攻击对象时，以自己墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80019195,1))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c80019195.settg)
	e3:SetOperation(c80019195.setop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且可以被除外的魔法·陷阱卡。
function c80019195.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove() and c:IsFaceup()
end
-- 效果①的靶向与发动条件判定函数（检查场上是否存在可除外的表侧表示魔陷，并选择该卡作为效果对象，设置除外操作信息）。
function c80019195.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c80019195.rmfilter(chkc) end
	-- 在发动阶段，检查场上是否存在至少1张满足条件的表侧表示魔法·陷阱卡作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(c80019195.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张满足条件的表侧表示魔法·陷阱卡，并将其注册为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c80019195.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果包含将所选卡片除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的效果处理函数（获取对象卡，若其仍存在于场上且呈表侧表示，则将其表侧表示除外）。
function c80019195.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的第1张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 因效果将目标卡片以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以盖放到场上的魔法卡。
function c80019195.setfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果②的靶向与发动条件判定函数（检查自身魔陷区是否有空位、墓地是否有可盖放的魔法卡，并选择该卡作为效果对象）。
function c80019195.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c80019195.setfilter(chkc) end
	-- 在发动阶段，首先检查当前玩家的魔法与陷阱区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并检查自己墓地中是否存在至少1张满足条件的魔法卡作为可选对象。
		and Duel.IsExistingTarget(c80019195.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1张满足条件的魔法卡，并将其注册为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c80019195.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果包含将所选卡片移出墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的效果处理函数（获取对象卡，若其仍与效果相关联，则将其在自己场上盖放）。
function c80019195.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的第1张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片在自己场上的魔法与陷阱区域盖放。
		Duel.SSet(tp,tc)
	end
end
