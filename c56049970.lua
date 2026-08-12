--水晶機巧－プラシレータ
-- 效果：
-- 「水晶机巧-绿晶龟」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「水晶机巧」怪兽特殊召唤。
function c56049970.initial_effect(c)
	-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56049970,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56049970)
	e1:SetTarget(c56049970.sptg1)
	e1:SetOperation(c56049970.spop1)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「水晶机巧」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56049970,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,56049970)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c56049970.sptg2)
	e2:SetOperation(c56049970.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的卡
function c56049970.desfilter(c)
	return c:IsFaceup()
end
-- 过滤条件：卡组中可以特殊召唤的「水晶机巧」调整怪兽
function c56049970.spfilter1(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择
function c56049970.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and c56049970.desfilter(chkc) end
	if chk==0 then
		-- 获取自己场上怪兽区域的空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查场上是否存在可以作为破坏对象的表侧表示卡片
		return Duel.IsExistingTarget(c56049970.desfilter,tp,loc,0,1,nil)
			-- 检查卡组中是否存在可以特殊召唤的「水晶机巧」调整怪兽
			and Duel.IsExistingMatchingCard(c56049970.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c56049970.desfilter,tp,e:GetLabel(),0,1,1,nil)
	-- 设置破坏操作的信息，包含选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置特殊召唤操作的信息，表示从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的执行处理
function c56049970.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的破坏对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍适用此效果，将其破坏，且破坏成功且怪兽区域有空位时
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「水晶机巧」调整怪兽
		local g=Duel.SelectMatchingCard(tp,c56049970.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。②：把墓地的这张卡除外才能发动。从手卡把1只「水晶机巧」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c56049970.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该限制效果，作用于玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：非机械族同调怪兽不能从额外卡组特殊召唤
function c56049970.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：手卡中可以特殊召唤的「水晶机巧」怪兽
function c56049970.spfilter2(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与可行性检查
function c56049970.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在可以特殊召唤的「水晶机巧」怪兽
		and Duel.IsExistingMatchingCard(c56049970.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作的信息，表示从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的执行处理
function c56049970.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域已无空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的「水晶机巧」怪兽
	local g=Duel.SelectMatchingCard(tp,c56049970.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
