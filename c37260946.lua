--D・イヤホン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时当作调整使用。
-- ②：以场上1只同调怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备卡使用给那只怪兽装备。
-- ③：有这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：添加同调召唤条件（调整＋调整以外的怪兽1只以上），启用苏生限制，然后生成并注册①特殊召唤变调整、②装备给同调怪兽、③装备怪兽可追加攻击这三个效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以1只调整＋1只以上调整以外的怪兽为素材，即本卡的同调召唤条件。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合各能使用1次。①：这张卡特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tntg)
	e1:SetOperation(s.tnop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合各能使用1次。②：以场上1只同调怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选出场上表侧表示且不是调整的怪兽，作为①效果可选的对象。
function s.tnfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- ①效果的目标函数：判定是否可行，若可行则让玩家从双方怪兽区选择1只表侧表示且非调整的怪兽作为对象。
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tnfilter(chkc) end
	-- 效果发动条件：场上存在至少1只表侧表示且非调整的怪兽时，①效果才可以发动。
	if chk==0 then return Duel.IsExistingTarget(s.tnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家：请选择表侧表示的卡（选择消息提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方怪兽区选择1只表侧表示且非调整的怪兽，并设置为①效果的对象。
	Duel.SelectTarget(tp,s.tnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：如果选择的对象仍与效果相关且表侧表示，则给对象怪兽附加‘当作调整’的效果，持续到回合结束。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：筛选出场上表侧表示的同调怪兽，作为②效果可装备的对象。
function s.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ②效果的目标函数：检查魔陷区空位、这张卡能否存在于场上以及是否存在可选的表侧同调怪兽；然后选择1只同调怪兽作为装备对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) and chkc~=c end
	-- 发动条件：自己的魔陷区需要有至少1个空位，用来放置这张装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp)
		-- 并且场上存在至少1只表侧表示同调怪兽（且不能是这张卡自身）作为可装备对象。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家：请选择要装备的怪兽（选择消息提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只表侧表示同调怪兽，作为这张卡的装备对象。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 当这张卡从墓地发动②效果时，向系统登记‘本操作涉及墓地的卡牌离开墓地’的信息，以便王家长眠之谷等效果进行制约。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- ②效果处理：若这张卡和对象仍满足装备条件，则把这张卡当作装备卡装备给对象同调怪兽，并设置只能装备给该怪兽的限制；若无法装备则将其送去墓地。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取②效果选择的同调怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 装备前检查：若魔陷区已无空位、对象怪兽变成里侧或不再与效果相关、或这张卡不能存在于场上，则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 装备失败时，将这张卡（因效果）送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试把这张卡装备到对象怪兽身上，若装备失败则终止后续处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 从自己的场上·墓地把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制函数：只有当目标卡是发动时选择的那只同调怪兽时，这张装备卡才能装备/继续装备在它身上。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
