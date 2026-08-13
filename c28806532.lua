--曇天気スレット
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在自己场上存在，这张卡以外的自己场上的表侧表示的「天气」卡被送去墓地的场合，以自己墓地最多2张「天气」魔法·陷阱卡为对象才能发动。那些卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c28806532.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在自己场上存在，这张卡以外的自己场上的表侧表示的「天气」卡被送去墓地的场合，以自己墓地最多2张「天气」魔法·陷阱卡为对象才能发动。那些卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28806532,0))  --"从墓地放置「天气」魔法·陷阱卡"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,28806532)
	e1:SetCondition(c28806532.tfcon)
	e1:SetTarget(c28806532.tftg)
	e1:SetOperation(c28806532.tfop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c28806532.spreg)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28806532,1))  --"除外的这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c28806532.spcon)
	e3:SetTarget(c28806532.sptg)
	e3:SetOperation(c28806532.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 判断被送去墓地的卡是否为“这张卡以外的自己场上表侧表示的天气卡”：需满足此前表侧表示、此前是天气卡、此前在场上且此前由自己控制。
function c28806532.tfcfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- ①效果的发动条件：本次被送去墓地的卡中存在1张以上满足条件的（此卡以外的自己场上的表侧表示天气卡），且不包含此卡自身。
function c28806532.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28806532.tfcfilter,1,e:GetHandler(),tp)
end
-- 墓地对象筛选：自己墓地的“天气”魔法·陷阱卡（场地魔法除外），且不是禁止卡、能在自己的魔法与陷阱区域表侧表示放置（检查场上同名卡限制）。
function c28806532.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的取对象处理：在自己的魔法与陷阱区域有空位的条件下，从自己墓地选择1~2张符合条件的“天气”魔法·陷阱卡作为对象。
function c28806532.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28806532.tffilter(chkc,tp) end
	-- 确认自己的魔法与陷阱区域是否有空位（用于放置对象）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认自己墓地存在至少1张可作为对象的“天气”魔法·陷阱卡。
		and Duel.IsExistingTarget(c28806532.tffilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向对方玩家提示我方发动了该效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 计算本次可选择的对象数量：最多2张，且不能超过自己的魔法与陷阱区域空位数。
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),2)
	-- 弹出选择提示，提示玩家从墓地选择要放置到场上的“天气”魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己墓地的符合条件的卡片中选择1~ct张作为对象（取对象）。
	local g=Duel.SelectTarget(tp,c28806532.tffilter,tp,LOCATION_GRAVE,0,1,ct,nil,tp)
	-- 设置本次操作信息：对象卡片将离开墓地，供相关卡片（如王家长眠之谷）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- ①效果处理：将作为对象的“天气”魔法·陷阱卡以表侧表示放置到自己的魔法与陷阱区域。
function c28806532.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象，并筛选出仍然与该效果有关联的对象（若对象已离开墓地则不处理）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<=0 then return end
	-- 效果处理时重新计算可放置的数量：最多2张，且不能超过当前魔陷区空位数。
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_SZONE)))
	if ct<1 then return end
	if g:GetCount()>ct then
		-- 提示玩家从仍符合条件的对象中选择要放置到场上的卡（当对象数超过可放置数时）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		g=g:Select(tp,1,ct,nil)
	end
	-- 遍历所有要放置的卡片。
	for tc in aux.Next(g) do
		-- 将选中的卡片移动到自己的魔法与陷阱区域，表侧表示放置（enable=true使卡立即适用效果/状态）。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- ②触发条件的记录：当场上的此卡因“天气”卡的效果发动的代价被除外时，记录下个准备阶段的回合数，并为此卡设置标记。
function c28806532.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 将下个回合的回合数存入效果标签，用于判断特殊召唤的时点。
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(28806532,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- ②效果发动的时机条件：当前为记录的下个回合的准备阶段，且此卡仍有记录标记。
function c28806532.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于之前记录的下个准备阶段回合数，且此卡存在标记（表示曾在除外时被登记）。
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(28806532)>0
end
-- ②效果发动时的合法性检查：确认自己的主要怪兽区域有空位，且此卡可以被特殊召唤。
function c28806532.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次操作信息：包含特殊召唤，对象为除外的此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(28806532)
end
-- ②效果处理：若除外的此卡仍与该效果关联，则将其特殊召唤。
function c28806532.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己的主要怪兽区域（检查召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
