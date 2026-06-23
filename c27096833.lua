--ヴァレルロード・L・ドラゴン
-- 效果：
-- 效果怪兽3只以上
-- 自己对「装弹枪管解放龙」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己·对方的战斗阶段才能发动（对方不能对应这个发动把卡的效果发动）。对方场上1只怪兽在这张卡所连接区放置得到控制权。
-- ②：自己·对方回合，这张卡在墓地存在的场合，以自己场上1只怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽破坏，这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括同名卡一回合只能特殊召唤一次的限制、连接召唤手续以及①和②效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 设置连接召唤手续：效果怪兽3只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己·对方的战斗阶段才能发动（对方不能对应这个发动把卡的效果发动）。对方场上1只怪兽在这张卡所连接区放置得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"得到控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_BATTLE_START+TIMING_BATTLE_END+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1)
	e1:SetCondition(s.cocon)
	e1:SetTarget(s.cotg)
	e1:SetOperation(s.coop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，这张卡在墓地存在的场合，以自己场上1只怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽破坏，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己·对方的战斗阶段
function s.cocon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为战斗阶段
	return Duel.IsBattlePhase()
end
-- 过滤可以改变控制权的对方怪兽：必须是可以改变控制权的怪兽，且需要放置在这张卡所连接区
function s.cfilter(c,ec)
	local zone=bit.band(ec:GetLinkedZone(),0x1f)
	return c:IsControlerCanBeChanged(false,zone)
end
-- ①效果的发动准备与目标检查（Target函数）：判断对方场上是否存在可以移至本卡连接区的可夺取控制权的怪兽，并设定操作信息和对方不能连锁的限制
function s.cotg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查对方场上是否存在至少1只满足过滤条件的怪兽
		return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,c)
	end
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
	-- 设置连锁条件限制（对方不能对应这个发动把卡的效果发动）
	Duel.SetChainLimit(s.chlimit)
end
-- 连锁限制的判定函数：仅允许本效果的发动玩家进行连锁
function s.chlimit(e,ep,tp)
	return tp==ep
end
-- ①效果的处理（Operation函数）：选择对方场上1只符合条件的怪兽，在所连接区放置并得到控制权
function s.coop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 给玩家提示：选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 由发动效果的玩家选择对方场上1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		-- 为被选择的怪兽卡片组显示选中动画
		Duel.HintSelection(g)
		local zone=bit.band(c:GetLinkedZone(),0x1f)
		-- 将选中的怪兽放置在这张卡所连接区的空位并得到控制权
		Duel.GetControl(tc,tp,0,0,zone)
	end
end
-- 过滤可以被破坏的自己怪兽：该怪兽离开场上后，自己场上必须有可用的怪兽区域以进行特殊召唤
function s.tfilter(c,tp)
	-- 判断目标怪兽离开后自己场上是否有空余的怪兽区域
	return Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的发动准备与目标检查（Target函数）：判断这张卡是否可以特殊召唤，以及自己场上是否存在可成为对象的怪兽，并在发动时选择自己场上1只怪兽作为破坏的对象，设置相关操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可以作为效果对象、且其离开后有特召区域的怪兽
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 给玩家提示：选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1只怪兽作为效果的对象并将其设为连锁对象
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理（Operation函数）：破坏作为对象的自己怪兽，并将墓地中的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若作为对象的卡在连锁处理时仍存在且是怪兽，则将其因效果破坏
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		-- 若墓地的这张卡仍然与连锁关联，且不受王家长眠之谷的影响
		if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 将这张卡以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
