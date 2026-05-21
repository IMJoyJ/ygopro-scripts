--ブンボーグ・ジェット
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「文具电子人喷气机」的②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的攻击力·守备力上升场上的「文具电子人」卡数量×500。
-- ②：以自己场上1张「文具电子人」卡为对象才能发动。那张卡破坏，从卡组把1只「文具电子人」怪兽特殊召唤。
-- ③：以自己场上1张「文具电子人」卡和场上1张表侧表示的卡为对象才能发动。那些卡破坏。
function c89544521.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升场上的「文具电子人」卡数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c89544521.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：以自己场上1张「文具电子人」卡为对象才能发动。那张卡破坏，从卡组把1只「文具电子人」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89544521,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,89544521)
	e3:SetTarget(c89544521.sptg)
	e3:SetOperation(c89544521.spop)
	c:RegisterEffect(e3)
	-- ③：以自己场上1张「文具电子人」卡和场上1张表侧表示的卡为对象才能发动。那些卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(89544521,1))  --"卡片破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,89544521)
	e4:SetTarget(c89544521.destg)
	e4:SetOperation(c89544521.desop)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示的「文具电子人」卡。
function c89544521.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xab)
end
-- 计算攻击力·守备力上升数值的函数。
function c89544521.val(e,c)
	-- 返回双方场上表侧表示的「文具电子人」卡数量×500。
	return Duel.GetMatchingGroupCount(c89544521.filter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*500
end
-- 过滤自己场上表侧表示的「文具电子人」卡。
function c89544521.desfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xab)
end
-- 过滤卡组中可以特殊召唤的「文具电子人」怪兽。
function c89544521.spfilter(c,e,tp)
	return c:IsSetCard(0xab) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（破坏并特召）的发动准备与目标选择。
function c89544521.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and c89544521.desfilter1(chkc) end
	if chk==0 then
		-- 获取自己场上可用的怪兽区域数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查自己场上是否存在可以作为破坏对象的「文具电子人」卡。
		return Duel.IsExistingTarget(c89544521.desfilter1,tp,loc,0,1,nil)
			-- 检查卡组中是否存在可以特殊召唤的「文具电子人」怪兽。
			and Duel.IsExistingMatchingCard(c89544521.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张「文具电子人」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c89544521.desfilter1,tp,e:GetLabel(),0,1,1,nil)
	-- 设置连锁信息：包含破坏1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②（破坏并特召）的效果处理。
function c89544521.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为破坏对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在于场上，则将其破坏，破坏成功时继续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 若自己场上没有可用的怪兽区域，则结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「文具电子人」怪兽。
		local g=Duel.SelectMatchingCard(tp,c89544521.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤自己场上表侧表示的「文具电子人」卡，且场上还存在其他表侧表示的卡。
function c89544521.desfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0xab)
		-- 检查场上是否存在除自身以外的表侧表示的卡。
		and Duel.IsExistingTarget(c89544521.desfilter3,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 过滤场上表侧表示的卡。
function c89544521.desfilter3(c)
	return c:IsFaceup()
end
-- 效果③（双重破坏）的发动准备与目标选择。
function c89544521.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以作为破坏对象的「文具电子人」卡。
	if chk==0 then return Duel.IsExistingTarget(c89544521.desfilter2,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的「文具电子人」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张「文具电子人」卡作为第一个破坏对象。
	local g1=Duel.SelectTarget(tp,c89544521.desfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择另一张要破坏的表侧表示卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示的卡（排除第一个对象）作为第二个破坏对象。
	local g2=Duel.SelectTarget(tp,c89544521.desfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置连锁信息：包含破坏这2张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果③（双重破坏）的效果处理。
function c89544521.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果关联的对象卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
