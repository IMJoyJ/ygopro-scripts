--イグナイト・ユナイト
-- 效果：
-- 「点火骑士团结」在1回合只能发动1张。
-- ①：以自己场上1张「点火骑士」卡为对象才能发动。那张卡破坏，从卡组把1只「点火骑士」怪兽特殊召唤。
function c38848158.initial_effect(c)
	-- 「点火骑士团结」在1回合只能发动1张。①：以自己场上1张「点火骑士」卡为对象才能发动。那张卡破坏，从卡组把1只「点火骑士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38848158+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38848158.target)
	e1:SetOperation(c38848158.activate)
	c:RegisterEffect(e1)
end
-- 破坏对象的选择条件：必须是表侧表示且持有「点火骑士」字段的卡片。
function c38848158.desfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xc8)
end
-- 特殊召唤的候选条件：卡组中的怪兽须持有「点火骑士」字段，且能够被该效果特殊召唤。
function c38848158.spfilter(c,e,tp)
	return c:IsSetCard(0xc8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的处理流程：先根据主怪兽区空格数决定可选对象范围，再确认存在可破坏的对象和可特殊召唤的怪兽；之后选择1张「点火骑士」卡作为对象，并登记破坏与特殊召唤的操作信息。
function c38848158.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and chkc~=c and c38848158.desfilter1(chkc) end
	if chk==0 then
		-- 获取tp玩家主要怪兽区的可用空格数量，用于判断特召空间及影响可选的破坏对象范围。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查在指定范围内是否存在至少1张满足条件的表侧「点火骑士」卡可以作为效果对象。
		return Duel.IsExistingTarget(c38848158.desfilter1,tp,loc,0,1,c)
			-- 检查卡组中是否存在至少1只满足条件的「点火骑士」怪兽可以特殊召唤。
			and Duel.IsExistingMatchingCard(c38848158.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 向操作者显示选择提示，告知需要选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从指定范围内选择1张表侧「点火骑士」卡作为效果对象（排除发动效果的卡自身）。
	local g=Duel.SelectTarget(tp,c38848158.desfilter1,tp,e:GetLabel(),0,1,1,c)
	-- 登记破坏操作信息：本次连锁将破坏已选择的1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记特殊召唤操作信息：本次连锁将从卡组把1只「点火骑士」怪兽特殊召唤到tp玩家场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的流程：若对象卡仍与效果关联，则将其破坏；破坏成功后，从卡组选择1只「点火骑士」怪兽特殊召唤到己方场上。
function c38848158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联，并以效果将其破坏；若破坏成功则继续处理特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 若己方主要怪兽区没有空位，则无法进行特殊召唤，直接结束本效果的后续处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向操作者显示选择提示，告知需要选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「点火骑士」怪兽，作为本次特殊召唤的对象。
		local g=Duel.SelectMatchingCard(tp,c38848158.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
