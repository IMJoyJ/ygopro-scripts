--エアーズロック・サンライズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只兽族怪兽为对象才能发动。那只兽族怪兽特殊召唤，对方场上有表侧表示怪兽存在的场合，那些怪兽的攻击力直到回合结束时下降自己墓地的兽族·鸟兽族·植物族怪兽数量×200。
function c42502956.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只兽族怪兽为对象才能发动。那只兽族怪兽特殊召唤，对方场上有表侧表示怪兽存在的场合，那些怪兽的攻击力直到回合结束时下降自己墓地的兽族·鸟兽族·植物族怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42502956+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c42502956.target)
	e1:SetOperation(c42502956.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：检查候选怪兽是否为兽族，且能否被当前效果特殊召唤（不检查召唤条件/苏生限制），用于选取对象。
function c42502956.filter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的取对象处理：验证所选对象是自己墓地的兽族且可特殊召唤；并在发动合法性检查中确认有怪兽区空位且墓地存在符合条件的兽族怪兽。
function c42502956.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c42502956.filter(chkc,e,tp) end
	-- 在效果发动合法性检查（chk==0）中，判断自己主要怪兽区域是否有空位，以确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续发动合法性检查：确认自己墓地存在至少1只满足筛选条件的兽族怪兽可以作为对象。
		and Duel.IsExistingTarget(c42502956.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家发送选择提示“请选择要特殊召唤的卡”，用于选择特殊召唤对象的界面显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的兽族怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c42502956.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时将要进行的特殊召唤操作信息（分类：特殊召唤，对象：g，数量：1），供连锁判定和后续效果联动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象并将其以表侧攻击表示特殊召唤；成功后获取对方场上表侧表示怪兽，计算自己墓地兽族·鸟兽族·植物族数量，为对方那些怪兽附加攻击力下降效果直到回合结束。
function c42502956.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的对象怪兽（第一张对象卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联且为兽族，然后将其以表侧攻击表示特殊召唤；仅当特殊召唤成功时才继续执行下降攻击力效果。
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_BEAST) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得对方场上的全部表侧表示怪兽，作为攻击力下降的适用对象。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		-- 统计自己墓地中兽族、鸟兽族、植物族怪兽的总数量，作为攻击力下降数值的基数。
		local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_BEAST+RACE_WINDBEAST+RACE_PLANT)
		tc=g:GetFirst()
		while tc do
			-- 那些怪兽的攻击力直到回合结束时下降自己墓地的兽族·鸟兽族·植物族怪兽数量×200。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*-200)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
