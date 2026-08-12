--エアーズロック・サンライズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只兽族怪兽为对象才能发动。那只兽族怪兽特殊召唤，对方场上有表侧表示怪兽存在的场合，那些怪兽的攻击力直到回合结束时下降自己墓地的兽族·鸟兽族·植物族怪兽数量×200。
function c42502956.initial_effect(c)
	-- ①：以自己墓地1只兽族怪兽为对象才能发动。那只兽族怪兽特殊召唤，对方场上有表侧表示怪兽存在的场合，那些怪兽的攻击力直到回合结束时下降自己墓地的兽族·鸟兽族·植物族怪兽数量×200。
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
-- 过滤满足条件的兽族怪兽，用于特殊召唤
function c42502956.filter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时判断是否满足发动条件
function c42502956.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c42502956.filter(chkc,e,tp) end
	-- 判断自己场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c42502956.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c42502956.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动
function c42502956.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽有效且为兽族，然后将其特殊召唤
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_BEAST) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		-- 统计自己墓地中的兽族、鸟兽族和植物族怪兽数量
		local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_BEAST+RACE_WINDBEAST+RACE_PLANT)
		tc=g:GetFirst()
		while tc do
			-- 使对方场上的所有表侧表示怪兽攻击力下降
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
