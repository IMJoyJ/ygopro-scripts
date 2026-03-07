--イグナイト・ユナイト
-- 效果：
-- 「点火骑士团结」在1回合只能发动1张。
-- ①：以自己场上1张「点火骑士」卡为对象才能发动。那张卡破坏，从卡组把1只「点火骑士」怪兽特殊召唤。
function c38848158.initial_effect(c)
	-- 效果原文内容：「点火骑士团结」在1回合只能发动1张。
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
-- 效果作用：筛选场上正面表示的「点火骑士」卡
function c38848158.desfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xc8)
end
-- 效果作用：筛选可以特殊召唤的「点火骑士」怪兽
function c38848158.spfilter(c,e,tp)
	return c:IsSetCard(0xc8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果原文内容：①：以自己场上1张「点火骑士」卡为对象才能发动。那张卡破坏，从卡组把1只「点火骑士」怪兽特殊召唤。
function c38848158.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and chkc~=c and c38848158.desfilter1(chkc) end
	if chk==0 then
		-- 效果作用：获取玩家tp的怪兽区域可用空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 效果作用：检查玩家tp的loc位置是否存在满足条件的「点火骑士」卡
		return Duel.IsExistingTarget(c38848158.desfilter1,tp,loc,0,1,c)
			-- 效果作用：检查玩家tp的卡组是否存在满足条件的「点火骑士」怪兽
			and Duel.IsExistingMatchingCard(c38848158.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择满足条件的「点火骑士」卡作为破坏对象
	local g=Duel.SelectTarget(tp,c38848158.desfilter1,tp,e:GetLabel(),0,1,1,c)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 效果作用：设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果原文内容：①：以自己场上1张「点火骑士」卡为对象才能发动。那张卡破坏，从卡组把1只「点火骑士」怪兽特殊召唤。
function c38848158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的破坏对象卡
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断破坏对象卡是否有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 效果作用：判断玩家场上是否有怪兽区域可用
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 效果作用：选择满足条件的「点火骑士」怪兽
		local g=Duel.SelectMatchingCard(tp,c38848158.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 效果作用：将选中的「点火骑士」怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
