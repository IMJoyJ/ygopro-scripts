--ドラグニティナイト－バルーチャ
-- 效果：
-- 龙族调整＋调整以外的鸟兽族怪兽1只以上
-- ①：这张卡同调召唤时，以自己墓地的龙族「龙骑兵团」怪兽任意数量为对象才能发动。那些龙族怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡装备的「龙骑兵团」卡数量×300。
function c25682811.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整怪兽必须为龙族，调整以外的怪兽必须为鸟兽族，素材数量为1只以上（即调整+至少1只调整以外鸟兽族怪兽）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时，以自己墓地的龙族「龙骑兵团」怪兽任意数量为对象才能发动。那些龙族怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25682811,0))  --"装备"
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c25682811.eqcon)
	e1:SetTarget(c25682811.eqtg)
	e1:SetOperation(c25682811.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡装备的「龙骑兵团」卡数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c25682811.atkval)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡以同调召唤方式成功特殊召唤时才能发动（对应①中“这张卡同调召唤时”）。
function c25682811.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 对象筛选条件：自己墓地的龙族怪兽且卡名带有「龙骑兵团」字段，并且不是禁止作为装备卡的卡。
function c25682811.filter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 目标指定处理：检查是否满足发动条件，并在发动时选择1到魔陷区空格数的任意数量符合条件的墓地龙族「龙骑兵团」怪兽作为效果对象。
function c25682811.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25682811.filter(chkc) end
	-- 发动条件检查：自己魔陷区必须有至少1个可用格（因为装备后的卡需要占用魔陷区）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：墓地中存在至少1张满足筛选条件的龙族「龙骑兵团」怪兽可以作为对象。
		and Duel.IsExistingTarget(c25682811.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 记录自己魔陷区的可用空格数，作为该效果可选择对象的数量上限（“任意数量”不能超过可装备格子数）。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 显示选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标：从自己墓地的满足条件的龙族「龙骑兵团」怪兽中，选择1到ft张（任意数量）作为效果对象。
	local g=Duel.SelectTarget(tp,c25682811.filter,tp,LOCATION_GRAVE,0,1,ft,nil)
	-- 设置操作信息：这些对象卡将从墓地离开，用于「王家长眠之谷」等涉及墓地的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：这些对象卡将被作为装备卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 效果处理：获取对象并过滤仍与效果关联的卡；若魔陷区空格不足则不处理；否则将每张对象卡依次装备给这张卡，并给每张装备卡添加“只能装备给此卡”的限制；最后完成装备处理。
function c25682811.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡组（目标卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 处理时再次确认魔陷区可用格数足以容纳全部对象，若不足则本效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<sg:GetCount() then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local tc=sg:GetFirst()
	while tc do
		-- 把对象卡tc作为装备卡装备给这张卡：保持原表示形式，且标记为分步装备，以便后续统一完成装备。
		Duel.Equip(tp,tc,c,false,true)
		-- 那些龙族怪兽当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c25682811.eqlimit)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
	end
	-- 装备处理完成，触发装备成功相关的时点。
	Duel.EquipComplete()
end
-- 装备限制条件：该装备卡只能装备给效果所有者（即这张同调怪兽），不能转装备给其他怪兽。
function c25682811.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 攻击力上升值：这张卡装备区中带有「龙骑兵团」字段的卡数量×300。
function c25682811.atkval(e,c)
	return c:GetEquipGroup():FilterCount(Card.IsSetCard,nil,0x29)*300
end
