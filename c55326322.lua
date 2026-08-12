--水晶機巧－ローズニクス
-- 效果：
-- 「水晶机巧-红晶雀」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。在自己场上把1只「水晶机巧衍生物」（机械族·水·1星·攻/守0）特殊召唤。这衍生物不能解放。
function c55326322.initial_effect(c)
	-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,55326322)
	e1:SetTarget(c55326322.sptg)
	e1:SetOperation(c55326322.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。在自己场上把1只「水晶机巧衍生物」（机械族·水·1星·攻/守0）特殊召唤。这衍生物不能解放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,55326322)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c55326322.tktg)
	e2:SetOperation(c55326322.tkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的卡片
function c55326322.desfilter(c)
	return c:IsFaceup()
end
-- 过滤条件：卡组中可以特殊召唤的「水晶机巧」调整怪兽
function c55326322.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测，选择自己场上1张表侧表示的卡作为对象，并确认卡组中存在可特招的「水晶机巧」调整
function c55326322.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and c55326322.desfilter(chkc) end
	if chk==0 then
		-- 获取自己场上可用怪兽区域的数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查自己场上是否存在至少1张可以作为破坏对象的表侧表示卡片
		return Duel.IsExistingTarget(c55326322.desfilter,tp,loc,0,1,nil)
			-- 检查卡组中是否存在至少1只可以特殊召唤的「水晶机巧」调整怪兽
			and Duel.IsExistingMatchingCard(c55326322.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c55326322.desfilter,tp,e:GetLabel(),0,1,1,nil)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：破坏对象卡，从卡组特殊召唤1只「水晶机巧」调整，并适用“不能从额外卡组特殊召唤机械族同调怪兽以外的怪兽”的限制
function c55326322.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选中的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍适用此效果，若成功破坏该卡且自己场上有空余怪兽区域，则继续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只满足条件的「水晶机巧」调整怪兽
		local g=Duel.SelectMatchingCard(tp,c55326322.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。②：把墓地的这张卡除外才能发动。在自己场上把1只「水晶机巧衍生物」（机械族·水·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c55326322.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，适用特殊召唤限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤机械族同调怪兽以外的怪兽
function c55326322.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动准备与合法性检测，确认自己场上有空余怪兽区域且可以特殊召唤衍生物
function c55326322.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的「水晶机巧衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,55326323,0xea,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_WATER) end
	-- 设置效果处理信息：产生1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的处理：在自己场上特殊召唤1只「水晶机巧衍生物」，并赋予其不能解放的限制
function c55326322.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有空余怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否无法特殊召唤指定的「水晶机巧衍生物」，若无法特招则直接返回
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,55326323,0xea,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_WATER) then return end
	-- 创建「水晶机巧衍生物」卡片数据
	local token=Duel.CreateToken(tp,55326323)
	-- 尝试将衍生物以表侧表示特殊召唤到自己场上（单步处理）
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物不能解放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	token:RegisterEffect(e2,true)
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
