--炎獣使いエーカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己或者对方的魔法与陷阱区域1张表侧表示的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
-- ②：以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作攻击力上升500的装备卡使用给这张卡装备。
function c35283277.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己或者对方的魔法与陷阱区域1张表侧表示的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35283277,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,35283277)
	e1:SetTarget(c35283277.sptg)
	e1:SetOperation(c35283277.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作攻击力上升500的装备卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35283277,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,35283278)
	e3:SetTarget(c35283277.eqtg)
	e3:SetOperation(c35283277.eqop)
	c:RegisterEffect(e3)
end
-- 判断魔法与陷阱区域的表侧表示怪兽是否满足特殊召唤条件：须表侧表示、位于主要魔陷区（非场地格）且可被特殊召唤。
function c35283277.spfilter(c,e,tp)
	return c:IsFaceup() and c:GetSequence()<5 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择与发动条件：校验目标位于魔陷区且满足spfilter；发动时还需确认主怪兽区有空位且存在可选目标。
function c35283277.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c35283277.spfilter(chkc,e,tp) end
	-- 自己主要怪兽区域必须存在可用的空格才能发动①效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 存在至少1张位于双方魔法与陷阱区域的表侧表示怪兽满足特殊召唤条件，可作为①效果的对象。
		and Duel.IsExistingTarget(c35283277.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	-- 向操作玩家显示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从符合条件的卡中选择1张作为①效果的对象，并登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c35283277.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	-- 记录本连锁将进行特殊召唤处理，目标为已选卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若对象卡仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c35283277.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断自己场上的表侧表示怪兽能否作为装备卡：须表侧表示、作为装备时满足唯一性限制且未被禁止。
function c35283277.eqfilter(c,tp)
	return c:IsFaceup() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- ②效果的目标选择与发动条件：目标须是自己场上表侧表示怪兽且不是本卡，并确认魔陷区有空位且存在可选目标。
function c35283277.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35283277.eqfilter(chkc,tp) and chkc~=c end
	-- 自己的魔法与陷阱区域必须存在可用的空格才能发动②效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 存在至少1张自己场上除本卡以外的表侧表示怪兽满足条件，可作为②效果的装备对象。
		and Duel.IsExistingTarget(c35283277.eqfilter,tp,LOCATION_MZONE,0,1,c,tp) end
	-- 向操作玩家显示选择提示，要求选择要装备的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从符合条件的怪兽中选择1张作为②效果的对象（不能选择本卡）。
	local g=Duel.SelectTarget(tp,c35283277.eqfilter,tp,LOCATION_MZONE,0,1,1,c,tp)
end
-- ②效果处理：将目标怪兽装备给本卡，若成功则附加装备限制和攻击力上升500的效果。
function c35283277.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果发动时选择的装备对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 尝试将对象怪兽作为装备卡装备给本卡（保持其当前表示形式）；装备失败则效果处理终止。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只表侧表示怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c35283277.eqlimit)
		tc:RegisterEffect(e1)
		-- 攻击力上升500。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 装备限制函数：仅允许该装备卡装备给本卡（埃卡）。
function c35283277.eqlimit(e,c)
	return c==e:GetLabelObject()
end
